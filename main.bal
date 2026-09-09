import ballerina/http;
import ballerina/io;
import api_health_aggregator.api;
import api_health_aggregator.user;
import api_health_aggregator.common;

configurable int SERVICE_PORT = ?;

listener http:Listener serviceListener = new (SERVICE_PORT);

service / on serviceListener {
    function init() {
        io:println(`[LOG] Web Service has started on port ${SERVICE_PORT}: http://localhost:${SERVICE_PORT}/`);
    }

    resource function get .() returns string {
        return "Welcome to API Health Aggregator";
    }
}

service /api on serviceListener {
    resource function get .(string? id) returns api:API|api:API[]|api:ApiError {
        if id is string {
            return api:get(id);
        }

        return api:getAll();
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

service /user on serviceListener {
    resource function get .(string? id) returns user:User|user:User[]|user:UserError {

        if id is string {
            return user:get(id);
        }

        return user:getAll();
    }

    resource function post users(user:ModifyUser modifyUser) returns user:User|user:UserError {
        return user:create(modifyUser);
    }

    resource function put users/[string id](user:ModifyUser modifyUser) returns user:User|user:UserError {
        return user:update(id, modifyUser);
    }

    resource function delete users/[string id]() returns common:DeletedResponse|user:UserError {
        return user:delete(id);
    }
}
