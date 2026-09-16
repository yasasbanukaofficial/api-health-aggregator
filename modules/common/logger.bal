import ballerina/io;

public isolated function logInfo(string message) {
    io:println(string `[LOG] ${message}`);
}

public isolated function logError(string message) {
    io:println(string `[ERROR] ${message}`);
}

public isolated function logDebug(string message) {
    io:println(string `[DEBUG] ${message}`);
}