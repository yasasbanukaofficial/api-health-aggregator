import ballerina/time;
public type APIHealth record {|
    readonly string apiHealthId;
    string status;
    int statusCode;
    time:Seconds responseTime;
    time:Utc checkedAt;

    string apiId;
|};