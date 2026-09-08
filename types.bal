import ballerina/time;
import ballerina/http;

// Error related records
type ErrorDetails record {|
    string msg;
    string details;
    time:Utc timeStamp;
|};

type NotFoundResponse record {|
    *http:NotFound;
    ErrorDetails body;
|};

// User related records
type User record {|
    readonly string userId;
    string name;
    string email;
    string phoneNumber;

    time:Date createdTime;
|};

// New User and Update User
type ModifyUser record {|
    string name;
    string email;
    string phoneNumber;
|};

// API related records
type API record {|
    readonly string apiId;
    string name;
    string apiURL;
    time:Date createdTime;
|};

// New API and Update API
type ModifyAPI record {|
    string name;
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