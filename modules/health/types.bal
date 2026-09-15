import ballerina/time;
public type APIHealth record {|
    readonly string apiHealthId;
    string status;
    int statusCode;
    int responseTime;
    time:Date checkedAt;

    string apiId;
|};