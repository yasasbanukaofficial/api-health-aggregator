import ballerina/http;
import ballerina/io;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;

public type DBConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
|};

const PORT = 9090;
configurable DBConfig dbConfig = ?;
final mysql:Client apiHealthDB = check initApiDb();

function initApiDb() returns mysql:Client|error => check new(...dbConfig);

service / on new http:Listener(PORT) {
    function init() {
        io:println(`[LOG] Web Service has started om port ${PORT}: http://localhost:${PORT}/`);
    }

    resource function get .() returns API[]|error {
        do {
            stream<API, sql:Error?> apiStream = 
                apiHealthDB->query(`SELECT * FROM api`);
            
            API[] apis = check from var api in apiStream select api;

            return apis;
        } on fail error err {
            io:println("Failed to fetch API's:  ", err.message());
            return err; 
        }
    }
}
