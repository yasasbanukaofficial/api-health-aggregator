import ballerina/io;
import ballerina/sql;
import ballerina/time;

import api_health_aggregator.database;

function getAllUsers() returns User[]|error {
    do {
        stream<User, sql:Error?> userStream = 
            database:apiHealthDB->query(`SELECT * FROM user`);

        User[] users = check from var user in userStream select user;
        return users;
    } on fail error err {
        io:println("Failed to fetch users:  ", err.message());
        return err; 
    }
}

function getUser(string id) returns User|error {
    do {
        User|error user = check database:apiHealthDB->queryRow(`SELECT * FROM user WHERE user_id = ${id}`);
        return user;
    } on fail var err {
        if err is sql:NoRowsError {
            io:println("Failed to fetch user:  ", err.message());
            return error(string `User with the id: ${id} not found`);
        }
        return err;
    }
}

function getUserByEmail(string email) returns User|error {
    do {
        User|error user = check database:apiHealthDB->queryRow(`SELECT * FROM user WHERE email = ${email}`);
        return user;
    } on fail var err {
        io:println("Failed to fetch user:  ", err.message());
        return error(string `User with the email: ${email} not found`);
    }
}

function isUserExisting(string email, string phoneNumber) returns boolean|error {
    User|error user = check database:apiHealthDB->queryRow(`SELECT * FROM user WHERE email = ${email} OR phone_number = ${phoneNumber}`);
    return user is User;
} 

function createUser(string newId, ModifyUser modifyUser, string hashedPassword) returns error? {
    do {
        sql:ExecutionResult result = check database:apiHealthDB->execute(`
            INSERT INTO user
            VALUES (
                ${newId},
                ${modifyUser.name},
                ${modifyUser.email},
                ${modifyUser.phoneNumber},
                ${hashedPassword},
                ${time:utcNow()}
            )
        `);

        if result.affectedRowCount == 0 {
            return error("SQL error when creating the user");
        }
    } on fail error err {
        io:println("Failed to create user: ", err.message());
        return err;
    }
}

function updateUser(string id, ModifyUser modifyUser) returns User|error {
    do {
        sql:ExecutionResult result = check database:apiHealthDB->execute(`
            UPDATE user 
            SET user_name = ${modifyUser.name}, email = ${modifyUser.email}, phone_number = ${modifyUser.phoneNumber}
            WHERE user_id = ${id}`);

        if result.affectedRowCount == 0 {
            return error(string `SQL error when modifying user with the id: ${id} not found`);
        }

        User updatedUser = check database:apiHealthDB->queryRow(`SELECT * FROM user WHERE user_id = ${id}`);
        return updatedUser;

    } on fail error err {
        io:println("Failed to update user:  ", err.message());
        return err;
    }
}

function updateUserPassword(string id, string hashedPassword) returns error? {
    do {
        sql:ExecutionResult result = check database:apiHealthDB->execute(`
            UPDATE user 
            SET password = ${hashedPassword}
            WHERE user_id = ${id}`);

        if result.affectedRowCount == 0 {
            return error(string `SQL error when modifying user with the id: ${id} not found`);
        }
    } on fail error err {
        io:println("Failed to update user password:  ", err.message());
        return err;
    }
}

function deleteUser(string id) returns error? {
    do {
        sql:ExecutionResult result = check database:apiHealthDB->execute(`
            DELETE FROM user WHERE user_id = ${id}`);

        if result.affectedRowCount == 0 {
            return error(string `SQL error when modifying user with the id: ${id} not found`);
        }

    } on fail error err {
        io:println("Failed to delete user:  ", err.message());
        return err;
    }
}
