import api_health_aggregator.api;
import api_health_aggregator.common;
import api_health_aggregator.user;
import api_health_aggregator.utils;

import ballerina/http;
import ballerina/io;

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

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000/"]
    }
}
service /api on serviceListener {
    @http:ResourceConfig{
        auth: [
            {
                jwtValidatorConfig: {
                    ...common:validatorConfig
                }
            }
        ]
    }
    resource function get .(http:RequestContext ctx) returns api:API|api:API[]|api:ApiError {
        string userId = check utils:getUserIdFromContext(ctx);
        return api:getAll(userId);
    }

    @http:ResourceConfig{
        auth: [
            {
                jwtValidatorConfig: {
                    ...common:validatorConfig
                }
            }
        ]
    }
    resource function get api/[string id](http:RequestContext ctx) returns api:API|api:ApiError {
        string userId = check utils:getUserIdFromContext(ctx);
        return api:get(userId, id);
    }

    @http:ResourceConfig{
        auth: [
            {
                jwtValidatorConfig: {
                    ...common:validatorConfig
                }
            }
        ]
    }
    resource function post api(http:RequestContext ctx, api:ModifyAPI modifyAPI) returns api:API|api:ApiError {
        string userId = check utils:getUserIdFromContext(ctx);
        return api:create(userId, modifyAPI);
    }

    @http:ResourceConfig{
        auth: [
            {
                jwtValidatorConfig: {
                    ...common:validatorConfig
                }
            }
        ]
    }
    resource function put api/[string id](http:RequestContext ctx, api:ModifyAPI modifyAPI) returns api:API|api:ApiError {
        string userId = check utils:getUserIdFromContext(ctx);
        return api:update(userId, id, modifyAPI);
    }

    @http:ResourceConfig{
        auth: [
            {
                jwtValidatorConfig: {
                    ...common:validatorConfig
                }
            }
        ]
    }
    resource function delete api/[string id](http:RequestContext ctx)
            returns common:DeletedResponse|api:ApiError {
        string userId = check utils:getUserIdFromContext(ctx);
        return api:delete(userId, id);
    }
}

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"]
    }
}
service /user on serviceListener {
    resource function post register(user:ModifyUser modifyUser) returns user:UserResponse|user:UserError {
        return user:register(modifyUser);
    }

    resource function post login(user:AuthUser authUser) returns user:UserResponse|user:UserError {
        return user:login(authUser);
    }

    @http:ResourceConfig{
        auth: [
            {
                jwtValidatorConfig: {
                    ...common:validatorConfig
                }
            }
        ]
    }
    resource function put update(
        http:RequestContext ctx,
        user:ModifyUser modifyUser
    ) returns user:User|user:UserError {
        string userId = check utils:getUserIdFromContext(ctx);
        return user:update(userId, modifyUser);
    }

    @http:ResourceConfig{
        auth: [
            {
                jwtValidatorConfig: {
                    ...common:validatorConfig
                }
            }
        ]
    }
    resource function delete delete(http:RequestContext ctx)
            returns common:DeletedResponse|user:UserError {
        string userId = check utils:getUserIdFromContext(ctx);
        return user:delete(userId);
    }
}
