import ballerina/http;
import ballerina/time;
import api_health_aggregator.common;
import api_health_aggregator.utils;
import ballerina/crypto;
public function get(string id) returns UserResponse|UserError|error {
    User|error user = getUser(id);

    if user is error {
        return userError(http:STATUS_NOT_FOUND, "Error when fetching user", user.message());
    }

    return mapToUserResponseFromUser(user, "");
}

public function register(NewUser newUser) returns UserResponse|UserError|error {

    if isUserExisting(newUser.email, newUser.phoneNumber) is true {
        return userError(http:STATUS_CONFLICT, "Error when creating user", string `User already exists with the email ${newUser.email}`);
    }

    string newId = utils:generateUUID();
    string hashedPassword = check crypto:hashBcrypt(newUser.password);

    error? createError = createUser(newId, newUser, hashedPassword);

    if createError is error {
        return userError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when creating user", "Error when creating user" + createError.message());
    }

    return <UserResponse> {
        ...mapToUserResponseFromNewUser(newUser, newId)
    };

}

public function login(AuthUser authUser) returns UserResponse|UserError|error {
    User|error existingUser = getUserByEmail(authUser.email);
    if existingUser is error {
        return userError(http:STATUS_NOT_FOUND, "Login Failed", existingUser.message());
    }

    if check crypto:verifyBcrypt(authUser.password, existingUser.password) is false {
        return userError(http:STATUS_UNAUTHORIZED, "Login failed", "Credentials don't match");
    }

    string|error jwtToken = utils:generateJwt(existingUser.userId);

    if jwtToken is error {
        return userError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when issuing token", jwtToken.message());
    }

    return <UserResponse>{
        ...mapToUserResponseFromUser(existingUser, jwtToken)
    };
}


public function update(string userId, ModifyUser modifyUser) returns User|UserError|error {
    if isUserExisting(modifyUser.email, modifyUser.phoneNumber) is true {
        return userError(http:STATUS_CONFLICT, "Error when updating user", "Update cannot happen because this email or phone number already exists.");
    }
    
    User|error updatedUser = updateUser(userId, modifyUser);

    if updatedUser is error {
        return userError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when updating user", updatedUser.message());
    }

    return updatedUser;
}

public function updatePassword(string userId, UpdatePassword updatePassword) returns User|UserError|error {
    User|error existingUser = getUser(userId);

    if existingUser is error {
        return userError(http:STATUS_NOT_FOUND, "Error when updating user password", existingUser.message());
    }

    if check crypto:verifyBcrypt(updatePassword.password, existingUser.password) is true {
        return userError(http:STATUS_BAD_REQUEST, "Error when updating user password", "New password cannot be the same as the current password");
    }

    string hashedPassword = check crypto:hashBcrypt(updatePassword.password);

    error? updateError = updateUserPassword(userId, hashedPassword);

    if updateError is error {
        return userError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when updating user password", updateError.message());
    }

    User|error updatedUser = getUser(userId);

    if updatedUser is error {
        return userError(http:STATUS_NOT_FOUND, "Error when updating user password", updatedUser.message());
    }

    return updatedUser;
}

public function delete(string userId) returns common:DeletedResponse|UserError|error {
    error? deleteError = deleteUser(userId);

    if deleteError is error {
        return userError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when deleting user", deleteError.message());
    }

    return <common:DeletedResponse>{
        body: {
            msg: "User deleted successfully",
            timeStamp: time:utcNow()
        }
    };
}


function mapToUserResponseFromUser(User user, string jwtToken) returns UserResponse => {userId: user.userId, name: user.name, email: user.email, phoneNumber: user.phoneNumber, jwtToken};
function mapToUserResponseFromNewUser(NewUser user, string newId, string? jwtToken = ()) returns UserResponse => {userId: newId, name: user.name, email: user.email, phoneNumber: user.phoneNumber, jwtToken: jwtToken};


