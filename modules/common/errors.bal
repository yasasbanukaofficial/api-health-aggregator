import ballerina/http;
import ballerina/time;

// Error related records
public type ErrorDetails record {|
    string msg;
    string details?;
    time:Utc timeStamp;
|};

public type DeletedResponse record {|
    *http:Ok;
    ErrorDetails body;
|};