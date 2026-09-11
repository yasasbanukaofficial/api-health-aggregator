import api_health_aggregator.api;
import api_health_aggregator.common;
import api_health_aggregator.user;

import ballerina/http;
import ballerina/io;
import ballerina/jwt;
import ballerina/time;

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
    resource function get .() returns api:API|api:API[]|api:ApiError {
        return api:getAll();
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
    resource function get api/[string id]() returns api:API|api:ApiError {
        return api:get(id);
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
    resource function post api(api:ModifyAPI modifyAPI) returns api:API|api:ApiError {
        return api:create(modifyAPI);
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
    resource function put api/[string id](api:ModifyAPI modifyAPI) returns api:API|api:ApiError {
        return api:update(id, modifyAPI);
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
    resource function delete api/[string id]() returns common:DeletedResponse|api:ApiError {
        return api:delete(id);
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

        [jwt:Header, jwt:Payload] jwtInformation =
            check ctx.getWithType(http:JWT_INFORMATION);

        jwt:Payload payload = jwtInformation[1];
        string? userId = payload.sub;

        if userId is () {
            return <user:ExecutionError>{
                body: {
                    msg: "Error when updating user",
                    details: "Invalid token",
                    timeStamp: time:utcNow()
                }
            };
        }

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

        [jwt:Header, jwt:Payload] jwtInformation =
            check ctx.getWithType(http:JWT_INFORMATION);

        jwt:Payload payload = jwtInformation[1];
        string? userId = payload.sub;

        if userId is () {
            return <user:ExecutionError>{
                body: {
                    msg: "Error when deleting user",
                    details: "Invalid token",
                    timeStamp: time:utcNow()
                }
            };
        }

        return user:delete(userId);
    }
}
