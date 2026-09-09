import ballerina/time;
import ballerina/constraint;
import ballerina/sql;

// User related records 
public type User record {|
    @sql:Column {
        name: "user_id"
    }
    readonly string userId;
    string name;
    string email;

    @sql:Column {
        name: "phone_number"
    }
    string phoneNumber;

    @sql:Column {
        name: "created_time"
    }
    time:Date createdTime;
|};

// New User and Update User
public type ModifyUser record {|
    @constraint:String {
        minLength: 2,
        maxLength: 50
    }
    string name;
    @constraint:String {
        pattern: re `/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/`
    }
    string email;
    @constraint:String {
        pattern: re `^\+?\d{1,3}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}$`
    }
    string phoneNumber;
|};
