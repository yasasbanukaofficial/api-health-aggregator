import ballerina/http;
import ballerina/jwt;

public isolated function validateJwt(string jwtToken) returns jwt:Payload|error {
    return check jwt:validate(jwtToken, validatorConfig = {...validatorConfig});
}

public isolated function generateJwt(string userId) returns string|error {
    do {
        jwt:IssuerConfig config = {...issueConfig, username: userId};
        string token = check jwt:issue(config);
        return token;
    } on fail error e {
        return (error("Error when generating JWT: " + e.message()));
    }
}

public isolated function getUserIdFromContext(http:RequestContext ctx) returns string|error {
    [jwt:Header, jwt:Payload] jwtInformation =
        check ctx.getWithType(http:JWT_INFORMATION);

    jwt:Payload payload = jwtInformation[1];
    string? userId = payload.sub;

    if userId is () {
        return error("Invalid token");
    }
    return userId;
}