import ballerina/http;
import api_health_aggregator.common;

public type ApiError ApiNotFound|ApiAlreadyExists|ExecutionError|error;

public type ApiNotFound record {|
    *http:NotFound;
    common:ErrorDetails body;
|};

public type ApiAlreadyExists record {|
    *http:Conflict;
    common:ErrorDetails body;
|};

public type ExecutionError record {|
    *http:InternalServerError;
    common:ErrorDetails body;
|};