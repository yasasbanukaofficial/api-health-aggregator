import ballerina/http;
import ballerina/time;
import api_health_aggregator.common;

public type ApiHealthError record {|
    *http:DefaultStatusCodeResponse;
    common:ErrorDetails body;
|};

public isolated function healthError(int statusCode, string msg, string? details = ()) returns ApiHealthError {
    return {
        status: new http:DefaultStatus(statusCode),
        body: {
            msg,
            details,
            timeStamp: time:utcNow()
        }
    };
}
