import ballerina/time;
import ballerina/http;

// Error related records
public type ErrorDetails record {|
    string msg;
    string details?;
    time:Utc timeStamp;
|};

public type DeletedResponse record {|
    *http:Ok;
    string body;
|};