import ballerina/time;
import api_health_aggregator.common;

public function getAll() returns User[]|ExecutionError|error {
    User[]|error users = check getAllUsers();

    if users is error {
        return {
            body: {msg: string `Error when fetching users`, details: users.message(), timeStamp: time:utcNow()}
        };
    }
    return users;
}

public function get(string id) returns User|ExecutionError|error {
    User|error user = check getUser(id);

    if user is error {
        return {
            body: {msg: string `Error when fetching user`, details: user.message(), timeStamp: time:utcNow()}
        };
    }
    return user;
}

public function register(ModifyUser modifyUser) returns User|UserAlreadyExists|ExecutionError|error {

    if getUserByEmail(modifyUser.email) is User {
        return <UserAlreadyExists>{
            body: {msg: "Error when creating user", details: string `User already exists with the email ${modifyUser.email}`, timeStamp: time:utcNow()}
        };
    }

    string newId = common:generateUUID();

    User|error newUser = check createUser(newId, modifyUser);

    if newUser is error {
        return <ExecutionError>{
            body: {msg: "Error when creating user", details: newUser.message(), timeStamp: time:utcNow()}
        };
    }

    return newUser;

}

public function login(string id) returns UserResponse|ExecutionError|error {
    User|error existingUser = check getUser(id);
    if existingUser is error {
        return <ExecutionError>{
            body: {msg: string `The user with the id: ${id} doesnt exist`, timeStamp: time:utcNow()}
        };
    }

    string|error jwtToken = check common:generateJwt(existingUser.userId);

    if jwtToken is error {
        return <ExecutionError> {
            body: {msg: "Error when issuing token", details: jwtToken.message(), timeStamp: time:utcNow()}
        };
    }

    return <UserResponse>{
        ...mapToUserResponse(existingUser, jwtToken)
    };
}


public function update(string id, ModifyUser modifyUser) returns User|ExecutionError|ExecutionError|error {
    User|error updatedUser = check updateUser(id, modifyUser);

    if updatedUser is error {
        if updatedUser.message().includes("not found") {
            return <ExecutionError>{
                body: {msg: "Error when updating user", details: updatedUser.message(), timeStamp: time:utcNow()}
            };
        }
        return <ExecutionError> {
            body: {msg: "Error when updating user", details: updatedUser.message(), timeStamp: time:utcNow()}
        };
    }

    return updatedUser;
}

public function delete(string id) returns common:DeletedResponse|ExecutionError|ExecutionError|error {
    error? result = check deleteUser(id);

    if result is error {
        if result.message().includes("not found") {
            return <ExecutionError>{
                body: {msg: "Error when deleting user", details: result.message(), timeStamp: time:utcNow()}
            };
        }
        return <ExecutionError>{
            body: {msg: "Error when deleting user", details: result.message(), timeStamp: time:utcNow()}
        };
    }

    common:DeletedResponse deleted = {
        body: "User deleted successfully"
    };
    return deleted;
}

function mapToUserResponse(User user, string jwtToken) returns UserResponse => {id: user.userId, name: user.name, email: user.email, phoneNumber: user.phoneNumber, password: user.password, jwtToken};
