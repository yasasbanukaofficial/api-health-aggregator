import ballerina/time;
import ballerina/sql;
public type APIHealth record {|
    readonly string apiHealthId;
    @sql:Column {
        name: "name"
    }
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