import ballerina/http;
import ballerina/io;
service / on new http:Listener(0) {
    function init() {
        io:println("[LOG] Web Service has started");
    }
}
