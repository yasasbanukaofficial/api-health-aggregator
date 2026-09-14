import ballerina/time;
import ballerina/constraint;
import ballerina/sql;

// API related records
public type API record {|
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
    time:Civil createdTime;

    @sql:Column {
        name: "user_id"
    }
    readonly string userId;
|};

// New API and Update API
public type ModifyAPI record {|
    @constraint:String {
        maxLength: 100
    }
    string name;
    @constraint:String {
        pattern: re `https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}([-a-zA-Z0-9()@:%_\+.~#?&//=]*)`
    }
    string apiURL;
|};

// API Health related records
public type APIHealth record {|
    readonly string apiHealthId;
    string status;
    int responseTime;
    time:Date checkedAt;
    API apiService;

    string apiId;
|};