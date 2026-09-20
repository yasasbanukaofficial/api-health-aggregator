import ballerina/time;
import ballerina/sql;

public type APIHealth record {|
    @sql:Column {
        name: "api_health_id"
    }
    readonly string apiHealthId;

    string status;

    @sql:Column {
        name: "status_code"
    }
    int statusCode;
    
    @sql:Column {
        name: "response_time"
    }
    time:Seconds responseTime;
    
    @sql:Column {
        name: "checked_at"
    }
    time:Utc checkedAt;

    @sql:Column {
        name: "api_id"
    }
    string apiId;
|};

public type APIHealthResponse record {|
    readonly string apiHealthId;
    string apiName;
    string status;
    int statusCode;
    time:Seconds responseTime;
    time:Utc checkedAt;

    string apiId;
|};

public type HealthTarget record {|
    string apiId;
    string apiName;
    string apiURL;
|};