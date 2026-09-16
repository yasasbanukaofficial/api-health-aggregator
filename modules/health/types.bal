import ballerina/time;
public type APIHealth record {|
    readonly string apiHealthId;
    string status;
    int statusCode;
    time:Seconds responseTime;
    time:Utc checkedAt;

    string apiId;
|};

public type APIHealthResponse record {|
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