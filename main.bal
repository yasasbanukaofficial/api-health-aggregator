import ballerina/http;
import ballerina/io;
import api_health_aggregator.api;
import api_health_aggregator.common;

configurable int SERVICE_PORT = ?;

service / on new http:Listener(SERVICE_PORT) {
    function init() {
        io:println(`[LOG] Web Service has started om port ${SERVICE_PORT}: http://localhost:${SERVICE_PORT}/`);
    }

    resource function get .() returns api:API[]|api:ApiError{
        return api:getAll();
    }
    
    resource function get api/[string id]() returns api:API|api:ApiError {
        return api:get(id);
    }

    resource function post api(api:ModifyAPI modifyAPI) returns api:API|api:ApiError {
        return api:create(modifyAPI);
    }

    resource function put api/[string id](api:ModifyAPI modifyAPI) returns api:API|api:ApiError {
        return api:update(id, modifyAPI);
    }

    resource function delete api/[string id]() returns common:DeletedResponse|api:ApiError {
        return api:delete(id);
    }
    
}

