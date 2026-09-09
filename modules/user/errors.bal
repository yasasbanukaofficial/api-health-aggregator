import ballerina/http;
import api_health_aggregator.common;

public type UserError UserNotFound|UserAlreadyExists|ExecutionError|error;

public type UserNotFound record {|
    *http:NotFound;
    common:ErrorDetails body;
|};

public type UserAlreadyExists record {|
    *http:Conflict;
    common:ErrorDetails body;
|};

public type ExecutionError record {|
    *http:InternalServerError;
    common:ErrorDetails body;
|};
