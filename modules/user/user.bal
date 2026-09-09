import ballerina/time;
import api_health_aggregator.common;

public function getAll() returns User[]|UserNotFound|error {
    User[]|error users = check getAllUsers();

    if users is error {
        UserNotFound userNotFound = {
            body: {msg: string `Error when fetching users`, details: users.message(), timeStamp: time:utcNow()}
        };
        return userNotFound;
    }
    return users;
}

public function get(string id) returns User|UserNotFound|error {
    User|error user = check getUser(id);

    if user is error {
        UserNotFound userNotFound = {
            body: {msg: string `Error when fetching user`, details: user.message(), timeStamp: time:utcNow()}
        };
        return userNotFound;
    }
    return user;
}

public function create(ModifyUser modifyUser) returns User|UserAlreadyExists|ExecutionError|error {

    if getUserByEmail(modifyUser.email) is User {
        UserAlreadyExists userAlreadyExists = {
            body: {msg: "Error when creating user", details: string `User already exists with the email ${modifyUser.email}`, timeStamp: time:utcNow()}
        };
        return userAlreadyExists;
    }

    string newId = common:generateUUID();

    User|error newUser = check createUser(newId, modifyUser);

    if newUser is error {
        ExecutionError executionError = {
            body: {msg: "Error when creating user", details: newUser.message(), timeStamp: time:utcNow()}
        };
        return executionError;
    }

    return newUser;

}

public function update(string id, ModifyUser modifyUser) returns User|UserNotFound|ExecutionError|error {
    User|error updatedUser = check updateUser(id, modifyUser);

    if updatedUser is error {
        if updatedUser.message().includes("not found") {
            UserNotFound userNotFound = {
                body: {msg: "Error when updating user", details: updatedUser.message(), timeStamp: time:utcNow()}
            };
            return userNotFound;
        }
        ExecutionError executionError = {
            body: {msg: "Error when updating user", details: updatedUser.message(), timeStamp: time:utcNow()}
        };
        return executionError;
    }

    return updatedUser;
}

public function delete(string id) returns common:DeletedResponse|UserNotFound|ExecutionError|error {
    error? result = check deleteUser(id);

    if result is error {
        if result.message().includes("not found") {
            UserNotFound userNotFound = {
                body: {msg: "Error when deleting user", details: result.message(), timeStamp: time:utcNow()}
            };
            return userNotFound;
        }
        ExecutionError executionError = {
            body: {msg: "Error when deleting user", details: result.message(), timeStamp: time:utcNow()}
        };
        return executionError;
    }

    common:DeletedResponse deleted = {
        body: "User deleted successfully"
    };
    return deleted;
}
