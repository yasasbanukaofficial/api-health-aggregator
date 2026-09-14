import ballerina/http;
import api_health_aggregator.common;

public type UserError UserAlreadyExists|ExecutionError|error;

public type ExecutionError record {|
    *http:NotFound;
    common:ErrorDetails body;
|};

public type UserAlreadyExists record {|
    *http:Conflict;
    common:ErrorDetails body;
|};
