import ballerina/time;
import api_health_aggregator.common;
import api_health_aggregator.utils;
import ballerina/jwt;
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

public function register(ModifyUser modifyUser) returns UserResponse|UserError|error {

    if getUserByEmail(modifyUser.email) is User {
        return <UserAlreadyExists>{
            body: {msg: "Error when creating user", details: string `User already exists with the email ${modifyUser.email}`, timeStamp: time:utcNow()}
        };
    }

    string newId = utils:generateUUID();
    
    string hashedPassword = check crypto:hashBcrypt(modifyUser.password);
    modifyUser.password = hashedPassword;
    
    error? createError = createUser(newId, modifyUser);

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


public function update(string jwtToken, ModifyUser modifyUser) returns User|ExecutionError|error {
    string userId = check retrieveUserId(jwtToken);
    User|error updatedUser = updateUser(userId, modifyUser);

    if updatedUser is error {
        return <ExecutionError> {
            body: {msg: "Error when updating user", details: updatedUser.message(), timeStamp: time:utcNow()}
        };
    }

    return updatedUser;
}

public function delete(string jwtToken) returns common:DeletedResponse|ExecutionError|error {
    string userId = check retrieveUserId(jwtToken);
    error? deleteError = deleteUser(userId);

    if deleteError is error {
        return error("Error when deleting user: " + deleteError.message());
    }

    return <common:DeletedResponse> {
        body: "User deleted successfully"
    };
}


function mapToUserResponseFromUser(User user, string jwtToken) returns UserResponse => {userId: user.userId, name: user.name, email: user.email, phoneNumber: user.phoneNumber, jwtToken};
function mapToUserResponseFromModifyUser(ModifyUser user, string newId, string? jwtToken = ()) returns UserResponse => {userId: newId, name: user.name, email: user.email, phoneNumber: user.phoneNumber, jwtToken: jwtToken};


function retrieveUserId(string jwtToken) returns string|error {
    jwt:Payload|error payloadResult = utils:validateJwt(jwtToken);
    if payloadResult is error {
        return error(payloadResult.message());
    }
    
    jwt:Payload payload = payloadResult;
    string? userId = payload.sub;

    if userId is () {
        return error("Invalid Token");
    }
    return userId;
}