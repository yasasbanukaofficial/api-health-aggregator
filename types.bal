import ballerina/time;
import ballerina/http;
import ballerina/constraint;
import ballerina/sql;

// Error related records
type ErrorDetails record {|
    string msg;
    time:Utc timeStamp;
|};

type NotFoundResponse record {|
    *http:NotFound;
    ErrorDetails body;
|};

type DeletedResponse record {|
    *http:Ok;
    string body;
|};

// User related records 
type User record {|
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
type ModifyUser record {|
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

// API related records
type API record {|
    @sql:Column {
        name: "api_id"
    }
    readonly string apiId;
    @sql:Column {
        name: "api_name"
    }
    string name;

    @sql:Column {
        name: "api_url"
    }
    string apiURL;
    @sql:Column {
        name: "created_time"
    }
    time:Date createdTime;
|};

// New API and Update API
type ModifyAPI record {|
    @constraint:String {
        maxLength: 100
    }
    string name;
    @constraint:String {
        pattern: re `https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)`
    }
    string apiURL;
|};

// API Health related records
type APIHealth record {|
    readonly string apiHealthId;
    string status;
    int responseTime;
    time:Date checkedAt;
    API apiService;

    string apiId;
|};