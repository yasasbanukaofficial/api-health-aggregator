import ballerina/time;
import ballerina/constraint;
import ballerina/sql;

// User related records 
public type User record {|
    @sql:Column {
        name: "user_id"
    }
    readonly string userId;
    @sql:Column {
        name: "user_name"
    }
    string name;
    string email;

    @sql:Column {
        name: "phone_number"
    }
    string phoneNumber;
    string password;

    @sql:Column {
        name: "created_time"
    }
    time:Civil createdTime;
|};

// New User and Update User
public type ModifyUser record {|
    @constraint:String {
        minLength: 2,
        maxLength: 50
    }
    string name;
    @constraint:String {
        pattern: re `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
    }
    string email;
    @constraint:String {
        pattern: re `^\+?\d{1,3}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}$`
    }
    string phoneNumber;
|};

public type NewUser record {|
    *ModifyUser; // Type inclusion
    string password;
|};

public type UpdatePassword record {|
    @constraint:String {
        minLength: 8,
        maxLength: 72
    }
    string password;
|};

public type AuthUser record {|
    string email;
    string password;
|};
public type UserResponse record {|
    readonly string userId;
    string name;
    string email;
    string phoneNumber;
    string? jwtToken = ();
|};