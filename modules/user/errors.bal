import ballerina/http;
import ballerina/time;
import api_health_aggregator.common;

public type UserError record {|
    *http:DefaultStatusCodeResponse;
    common:ErrorDetails body;
|};

public function userError(int statusCode, string msg, string? details = ()) returns UserError {
    return {
        status: new http:DefaultStatus(statusCode),
        body: {
            msg,
            details,
            timeStamp: time:utcNow()
        }
    };
}