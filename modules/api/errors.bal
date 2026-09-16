import ballerina/http;
import ballerina/time;
import api_health_aggregator.common;

public type ApiError record {|
    *http:DefaultStatusCodeResponse;
    common:ErrorDetails body;
|};

public isolated function apiError(int statusCode, string msg, string? details = ()) returns ApiError {
    return {
        status: new http:DefaultStatus(statusCode),
        body: {
            msg,
            details,
            timeStamp: time:utcNow()
        }
    };
}