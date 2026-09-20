import api_health_aggregator.api;
import api_health_aggregator.common;
import api_health_aggregator.user;

import ballerina/http;
import ballerina/log;
import api_health_aggregator.health;

configurable int SERVICE_PORT = ?;

listener http:Listener serviceListener = new (SERVICE_PORT);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"]
    }
}
service / on serviceListener {
    function init() {
        log:printInfo(string `Web Service has started on port ${SERVICE_PORT}: http://localhost:${SERVICE_PORT}/`);
    }

    resource isolated function get .() returns string {
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
    resource isolated function get api(http:RequestContext ctx) returns api:API|api:API[]|api:ApiError|error {
        string userId = check common:getUserIdFromContext(ctx);
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
    resource isolated function get api/[string id](http:RequestContext ctx) returns api:API|api:ApiError|error {
        string userId = check common:getUserIdFromContext(ctx);
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
    resource isolated function post api(http:RequestContext ctx, api:ModifyAPI modifyAPI) returns api:API|api:ApiError|error {
        string userId = check common:getUserIdFromContext(ctx);
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
    resource isolated function put api/[string id](http:RequestContext ctx, api:ModifyAPI modifyAPI) returns api:API|api:ApiError|error {
        string userId = check common:getUserIdFromContext(ctx);
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
    resource isolated function delete api/[string id](http:RequestContext ctx)
            returns common:DeletedResponse|api:ApiError|error {
        string userId = check common:getUserIdFromContext(ctx);
        return api:delete(userId, id);
    }

    resource isolated function post user/register(user:NewUser newUser) returns user:UserResponse|user:UserError|error {
        return user:register(newUser);
    }

    resource isolated function post user/login(user:AuthUser authUser) returns user:UserResponse|user:UserError|error {
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
    resource isolated function put user/update(
        http:RequestContext ctx,
        user:ModifyUser modifyUser
) returns user:User|user:UserError|error {
        string userId = check common:getUserIdFromContext(ctx);
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
    resource isolated function put user/password(http:RequestContext ctx, user:UpdatePassword updatePassword) returns user:User|user:UserError|error {
        string userId = check common:getUserIdFromContext(ctx);
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
    resource isolated function delete user/delete(http:RequestContext ctx)
            returns common:DeletedResponse|user:UserError|error {
        string userId = check common:getUserIdFromContext(ctx);
        return user:delete(userId);
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
    resource isolated function get health(http:RequestContext ctx) returns health:APIHealth[]|api:ApiError|health:ApiHealthError|error {
        string userId = check common:getUserIdFromContext(ctx);
        return api:getAllHealth(userId);
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
    resource isolated function get health/[string apiId](http:RequestContext ctx) returns health:APIHealth|api:ApiError|health:ApiHealthError|error {
        string userId = check common:getUserIdFromContext(ctx);
        return api:getHealth(userId, apiId);
    }
}