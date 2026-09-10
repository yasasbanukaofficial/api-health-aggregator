import ballerina/jwt;
public type JwtValidatorConfig record {|
    string issuer;
    string audience;
    jwt:ValidatorSignatureConfig signatureConfig;
|};