import api_health_aggregator.api;
import api_health_aggregator.common;
import api_health_aggregator.user;

import ballerina/http;
import ballerina/io;

configurable int SERVICE_PORT = ?;
configurable string JWT_SECRET = ?;

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
    },
    auth: [{jwtValidatorConfig: {...common:validatorConfig}}]
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

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000/"]
    },
    auth: [
        {
            jwtValidatorConfig: {
                issuer: "doeCompany",
                audience: "apiAud",
                signatureConfig: {
                    secret: JWT_SECRET
                }
            }
        }
    ]
}
service /user on serviceListener {
    resource function get .(string? id) returns user:User|user:User[]|user:UserError {

        if id is string {
            return user:get(id);
        }

        return user:getAll();
    }

    resource function post register(user:ModifyUser modifyUser) returns user:User|user:UserError {
        return user:register(modifyUser);
    }

    resource function put update/[string id](user:ModifyUser modifyUser) returns user:User|user:UserError {
        return user:update(id, modifyUser);
    }

    resource function delete delete/[string id]() returns common:DeletedResponse|user:UserError {
        return user:delete(id);
    }
}
