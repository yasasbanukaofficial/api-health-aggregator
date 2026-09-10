import ballerina/uuid;
import ballerina/jwt;
import api_health_aggregator.common;

public function generateUUID() returns string => uuid:createRandomUuid();

public function validateJwt(string jwtToken, string userId) returns boolean|error {
    do {
	    jwt:Payload rslt = check jwt:validate(jwtToken, validatorConfig = {...common:validatorConfig});
        if rslt.sub != userId {
            return false;
        }
        return true;
    } on fail error e {
        return error("Error when validating JWT: " + e.message());
    }
}

public function generateJwt(string userId) returns string|error {
    do {
        jwt:IssuerConfig config = common:issueConfig;
        config.username = userId;
        return check jwt:issue(config);
    } on fail error e {
        return (error("Error when generating JWT: " + e.message()));
    }
}