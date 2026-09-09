import ballerina/io;
import ballerina/sql;
import api_health_aggregator.database;
import ballerina/time;

function getAllApi() returns API[]|error {
    do {
        stream<API, sql:Error?> apiStream = 
            database:apiHealthDB->query(`SELECT * FROM api`);
        
        API[] apis = check from var api in apiStream select api;
        return apis;
    } on fail error err {
        io:println("Failed to fetch API's:  ", err.message());
        return err; 
    }
}

function getApi(string id) returns API|error {
    do {
        API|error user = check database:apiHealthDB->queryRow(`SELECT * FROM api WHERE api_id = ${id}`);
        return user;
    } on fail var err {
        if err is sql:NoRowsError {
            io:println("Failed to fetch API's:  ", err.message());
            return error(string `API with the id: ${id} not found`);
        }
        return err;
    }
}

function getApiByName(string name) returns API|error {
    do {
        API|error user = check database:apiHealthDB->queryRow(`SELECT * FROM api WHERE api_name = ${name}`);
        return user;
    } on fail var err {
        if err is sql:NoRowsError {
            io:println("Failed to fetch API's:  ", err.message());
            return error(string `API with the id: ${name} not found`);
        }
        return err;
    }
}

function createApi(string newId, ModifyAPI modifyAPI) returns API|error {
    do {
        API|sql:Error api = database:apiHealthDB->queryRow(`
            INSERT INTO api 
            VALUES (${newId}, ${modifyAPI.name}, ${modifyAPI.apiURL}, ${time:utcNow()});`);
        return api;
    } on fail var err {
        io:println("Failed to fetch API's:  ", err.message());
        return err;
    }
}

function updateApi(string id, ModifyAPI modifyAPI) returns API|error {
    do {
        sql:ExecutionResult result = check database:apiHealthDB->execute(`
            UPDATE api 
            SET api_name = ${modifyAPI.name}, api_url = ${modifyAPI.apiURL}
            WHERE api_id = ${id}`);

        if result.affectedRowCount == 0 {
            return error(string `API with the id: ${id} not found`);
        }

        API updatedApi = check database:apiHealthDB->queryRow(`SELECT * FROM api WHERE api_id = ${id}`);
        return updatedApi;

    } on fail error err {
        io:println("Failed to update API:  ", err.message());
        return err;
    }
}

function deleteApi(string id) returns error? {
    do {
        sql:ExecutionResult result = check database:apiHealthDB->execute(`
            DELETE FROM api WHERE api_id = ${id}`);

        if result.affectedRowCount == 0 {
            return error(string `API with the id: ${id} not found`);
        }

    } on fail error err {
        io:println("Failed to delete API:  ", err.message());
        return err;
    }
}