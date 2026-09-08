import ballerina/http;
import ballerina/io;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;
import ballerina/time;
import ballerina/uuid;

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
    
    resource function get api/[string id]() returns API|NotFoundResponse|error {
        do {
            API|error user = check apiHealthDB->queryRow(`SELECT * FROM api WHERE apiId = ${id}`);
            return user;
        } on fail var err {
            if err is sql:NoRowsError {
                io:println("Failed to fetch API's:  ", err.message());
                ErrorDetails errorDetails = {
                    msg: err.message(),
                    timeStamp: time:utcNow()
                };
                
                NotFoundResponse notFound = {
                    body: {...errorDetails}
                };

                return notFound;
            }
            return err;
        }
    }

    resource function post api(ModifyAPI modifyAPI) returns API|NotFoundResponse|error {
        string newId = generateUUID();

        API|sql:Error api = apiHealthDB->queryRow(`
            INSERT INTO api 
            VALUES (${newId}, ${modifyAPI.name}, ${modifyAPI.apiURL}, ${time:utcNow()});`);

        if api is sql:NoRowsError {
            io:println("Failed to create API:  ", api.message());
            ErrorDetails errorDetails = {
                msg: api.message(),
                timeStamp: time:utcNow()
            };

            NotFoundResponse notFound = {
                body: {...errorDetails}
            };

            return notFound;
        }

        return api;
    }

    resource function put api/[string id](ModifyAPI modifyAPI) returns API|NotFoundResponse|error {
        do {
            sql:ExecutionResult result = check apiHealthDB->execute(`
                UPDATE api 
                SET name = ${modifyAPI.name}, apiURL = ${modifyAPI.apiURL}
                WHERE apiId = ${id}`);

            if result.affectedRowCount == 0 {
                ErrorDetails errorDetails = {
                    msg: "API not found",
                    timeStamp: time:utcNow()
                };

                NotFoundResponse notFound = {
                    body: {...errorDetails}
                };

                return notFound;
            }

            API updatedApi = check apiHealthDB->queryRow(`SELECT * FROM api WHERE apiId = ${id}`);
            return updatedApi;
        } on fail error err {
            io:println("Failed to update API:  ", err.message());
            return err;
        }
    }

    resource function delete api/[string id]() returns DeletedResponse|NotFoundResponse|error {
        do {
            sql:ExecutionResult result = check apiHealthDB->execute(`
                DELETE FROM api WHERE apiId = ${id}`);

            if result.affectedRowCount == 0 {
                ErrorDetails errorDetails = {
                    msg: "API not found",
                    timeStamp: time:utcNow()
                };

                NotFoundResponse notFound = {
                    body: {...errorDetails}
                };

                return notFound;
            }

            DeletedResponse deleted = {
                body: "API deleted successfully"
            };

            return deleted;
        } on fail error err {
            io:println("Failed to delete API:  ", err.message());
            return err;
        }
    }
    
}

function generateUUID() returns string => uuid:createRandomUuid();
