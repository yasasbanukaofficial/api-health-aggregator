import ballerina/uuid;
import ballerina/http;
import ballerina/jwt;
import api_health_aggregator.common;

public function generateUUID() returns string => uuid:createRandomUuid();

public function validateJwt(string jwtToken) returns jwt:Payload|error {
    return check jwt:validate(jwtToken, validatorConfig = {...common:validatorConfig});
}

public function generateJwt(string userId) returns string|error {
    do {
        jwt:IssuerConfig config = {...common:issueConfig, username: userId};
        string token = check jwt:issue(config);
        return token;
    } on fail error e {
        return (error("Error when generating JWT: " + e.message()));
    }
}

public function getUserIdFromContext(http:RequestContext ctx) returns string|error {
    [jwt:Header, jwt:Payload] jwtInformation =
        check ctx.getWithType(http:JWT_INFORMATION);

    jwt:Payload payload = jwtInformation[1];
    string? userId = payload.sub;

    if userId is () {
        return error("Invalid token");
    }
    return userId;
}