import ballerina/jwt;

public configurable jwt:ValidatorConfig validatorConfig = ?;

public type IssueConfig record {|
    string issuer?;
    string|string[] audience?;
    string jwtId?;
    string keyId?;
    map<json> customClaims?;
    decimal expTime = 300;
    jwt:IssuerSignatureConfig signatureConfig?;
|};

public configurable IssueConfig issueConfig = ?;
