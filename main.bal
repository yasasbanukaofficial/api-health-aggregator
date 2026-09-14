import api_health_aggregator.api;
import api_health_aggregator.common;
import api_health_aggregator.user;
import api_health_aggregator.utils;

import ballerina/http;
import ballerina/io;

configurable int SERVICE_PORT = ?;

listener http:Listener serviceListener = new (SERVICE_PORT);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"]
    }
}
service / on serviceListener {
    function init() {
        io:println(`[LOG] Web Service has started on port ${SERVICE_PORT}: http://localhost:${SERVICE_PORT}/`);
    }

    resource function get .() returns string {
        return "Welcome to API Health Aggregator";
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
    resource function get api(http:RequestContext ctx) returns api:API|api:API[]|api:ApiError {
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

    resource function post user/register(user:NewUser newUser) returns user:UserResponse|user:UserError {
        return user:register(newUser);
    }

    resource function post user/login(user:AuthUser authUser) returns user:UserResponse|user:UserError {
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
    resource function put user/update(
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
    resource function put user/password(http:RequestContext ctx, user:UpdatePassword updatePassword) returns user:User|user:UserError {
        string userId = check utils:getUserIdFromContext(ctx);
        return user:updatePassword(userId, updatePassword);
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
    resource function delete user/delete(http:RequestContext ctx)
            returns common:DeletedResponse|user:UserError {
        string userId = check utils:getUserIdFromContext(ctx);
        return user:delete(userId);
    }
}