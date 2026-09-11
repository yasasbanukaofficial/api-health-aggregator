import ballerina/time;
import api_health_aggregator.common;
import api_health_aggregator.utils;
import ballerina/crypto;

public function getAll() returns User[]|ExecutionError|error {
    User[]|error users = getAllUsers();
    
    if users is error {
        return {
            body: {msg: string `Error when fetching users`, details: users.message(), timeStamp: time:utcNow()}
        };
    }
    return users;
}

public function get(string id) returns User|ExecutionError|error {
    User|error user = getUser(id);

    if user is error {
        return <ExecutionError> {
            body: {msg: string `Error when fetching user`, details: user.message(), timeStamp: time:utcNow()}
        };
    }

    return user;
}

public function register(NewUser newUser) returns UserResponse|UserError|error {

    if isUserExisting(newUser.email, newUser.phoneNumber) is true {
        return <UserAlreadyExists>{
            body: {msg: "Error when creating user", details: string `User already exists with the email ${newUser.email}`, timeStamp: time:utcNow()}
        };
    }

    string newId = utils:generateUUID();

    ModifyUser modifyUser = {
        name: newUser.name,
        email: newUser.email,
        phoneNumber: newUser.phoneNumber
    };

    string hashedPassword = check crypto:hashBcrypt(newUser.password);

    error? createError = createUser(newId, modifyUser, hashedPassword);

    if createError is error {
        return <ExecutionError>{
            body: {msg: "Error when creating user", details: "Error when creating user" + createError.message(), timeStamp: time:utcNow()}
        };
    }

    return <UserResponse> {
        ...mapToUserResponseFromModifyUser(modifyUser, newId)
    };

}

public function login(AuthUser authUser) returns UserResponse|ExecutionError|error {
    User|error existingUser = getUserByEmail(authUser.email);
    if existingUser is error {
        return <ExecutionError>{
            body: {msg: string `Login Failed`, details: string `The user with the email: ${authUser.email} doesn't exist ${existingUser.message()}`, timeStamp: time:utcNow()}
        };
    }

    if check crypto:verifyBcrypt(authUser.password, existingUser.password) is false {
        return <ExecutionError>{
            body: {msg: "Login failed", details: "Credentials don't match", timeStamp: time:utcNow()}
        };
    }

    string|error jwtToken = utils:generateJwt(existingUser.userId);

    if jwtToken is error {
        return <ExecutionError> {
            body: {msg: "Error when issuing token", details: jwtToken.message(), timeStamp: time:utcNow()}
        };
    }

    return <UserResponse>{
        ...mapToUserResponseFromUser(existingUser, jwtToken)
    };
}


public function update(string userId, ModifyUser modifyUser) returns User|ExecutionError|error {
    if isUserExisting(modifyUser.email, modifyUser.phoneNumber) is true {
        return <ExecutionError>{
            body: {
                msg: "Error when updating user",
                details: "Update cannot happen because this email or phone number already exists.",
                timeStamp: time:utcNow()
            }
        };
    }
    
    User|error updatedUser = updateUser(userId, modifyUser);

    if updatedUser is error {
        return <ExecutionError> {
            body: {msg: "Error when updating user", details: updatedUser.message(), timeStamp: time:utcNow()}
        };
    }

    return updatedUser;
}

public function updatePassword(string userId, UpdatePassword updatePassword) returns User|ExecutionError|error {
    User|error existingUser = getUser(userId);

    if existingUser is error {
        return <ExecutionError>{
            body: {msg: "Error when updating user password", details: existingUser.message(), timeStamp: time:utcNow()}
        };
    }

    if check crypto:verifyBcrypt(updatePassword.password, existingUser.password) is true {
        return <ExecutionError>{
            body: {msg: "Error when updating user password", details: "New password cannot be the same as the current password", timeStamp: time:utcNow()}
        };
    }

    string hashedPassword = check crypto:hashBcrypt(updatePassword.password);

    error? updateError = updateUserPassword(userId, hashedPassword);

    if updateError is error {
        return <ExecutionError>{
            body: {msg: "Error when updating user password", details: updateError.message(), timeStamp: time:utcNow()}
        };
    }

    User|error updatedUser = getUser(userId);

    if updatedUser is error {
        return <ExecutionError>{
            body: {msg: "Error when updating user password", details: updatedUser.message(), timeStamp: time:utcNow()}
        };
    }

    return updatedUser;
}

public function delete(string userId) returns common:DeletedResponse|ExecutionError|error {
    error? deleteError = deleteUser(userId);

    if deleteError is error {
        return <ExecutionError>{
            body: {
                msg: "Error when deleting user",
                details: deleteError.message(),
                timeStamp: time:utcNow()
            }
        };
    }

    return <common:DeletedResponse> {
        body: "User deleted successfully"
    };
}


function mapToUserResponseFromUser(User user, string jwtToken) returns UserResponse => {userId: user.userId, name: user.name, email: user.email, phoneNumber: user.phoneNumber, jwtToken};
function mapToUserResponseFromModifyUser(ModifyUser user, string newId, string? jwtToken = ()) returns UserResponse => {userId: newId, name: user.name, email: user.email, phoneNumber: user.phoneNumber, jwtToken: jwtToken};


