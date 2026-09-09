import ballerina/uuid;

public function generateUUID() returns string => uuid:createRandomUuid();