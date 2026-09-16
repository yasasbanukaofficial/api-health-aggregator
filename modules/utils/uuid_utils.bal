import ballerina/uuid;

public isolated function generateUUID() returns string => uuid:createRandomUuid();