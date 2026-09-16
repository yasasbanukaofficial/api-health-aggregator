import ballerina/io;
import ballerina/sql;
import ballerina/time;
import api_health_aggregator.database;

isolated function getAllApi(string userId) returns API[]|error {
    do {
        stream<API, sql:Error?> apiStream =
            database:apiHealthDB->query(`SELECT * FROM api WHERE user_id = ${userId}`);
        API[] apis = check from var api in apiStream select api;
        return apis;
    } on fail error err {
        io:println("Failed to fetch APIs: ", err.message());
        return err;
    }
}

isolated function getApi(string userId, string apiId) returns API|error {
    do {
        API api = check database:apiHealthDB->queryRow(
            `SELECT * FROM api WHERE api_id = ${apiId} AND user_id = ${userId}`);
        return api;
    } on fail error err {
        if err is sql:NoRowsError {
            io:println("API not found: ", err.message());
            return error(string `API with the id: ${apiId} not found`);
        }
        io:println("Failed to fetch API: ", err.message());
        return err;
    }
}

isolated function getApiByName(string userId, string apiUrl) returns API|error {
    do {
        API api = check database:apiHealthDB->queryRow(
            `SELECT * FROM api WHERE api_url = ${apiUrl} AND user_id=${userId}`);
        return api;
    } on fail error err {
        if err is sql:NoRowsError {
            return error(string `API with the apiUrl: ${apiUrl} not found`);
        }
        io:println("Failed to fetch API: ", err.message());
        return err;
    }
}

isolated function getUrlByApiId(string userId, string apiId) returns string|error {
    do {
        string|error apiUrl = check database:apiHealthDB->queryRow(
            `SELECT api_url FROM api WHERE api_id=${apiId} AND user_id=${userId}`
        );
        return apiUrl;
    } on fail error err {
        if err is sql:NoRowsError {
            return error(string `API with the api Id: ${apiId} not found`);
        }
        io:println("Failed to fetch API: ", err.message());
        return err;
    }
} 


isolated function createApi(string newId, string userId, ModifyAPI modifyAPI) returns error? {
    do {
        sql:ExecutionResult result = check database:apiHealthDB->execute(`
            INSERT INTO api
            VALUES (${newId}, ${modifyAPI.name}, ${modifyAPI.apiURL}, ${userId}, ${time:utcNow()});`);

        if result.affectedRowCount == 0 {
            return error("SQL error when creating the api");
        }
    } on fail error err {
        io:println("Failed to create API: ", err.message());
        return err;
    }
}

isolated function updateApi(string userId, string id, ModifyAPI modifyAPI) returns API|error {
    do {
        sql:ExecutionResult result = check database:apiHealthDB->execute(`
            UPDATE api
            SET api_name = ${modifyAPI.name}, api_url = ${modifyAPI.apiURL}
            WHERE api_id = ${id} AND user_id = ${userId}`);

        if result.affectedRowCount == 0 {
            return error(string `API with the id: ${id} not found`);
        }

        API updatedApi = check database:apiHealthDB->queryRow(
            `SELECT * FROM api WHERE api_id = ${id} AND user_id = ${userId}`);
        return updatedApi;

    } on fail error err {
        if err is sql:NoRowsError {
            io:println("API not found after update: ", err.message());
            return error(string `API with the id: ${id} not found`);
        }
        io:println("Failed to update API: ", err.message());
        return err;
    }
}

isolated function deleteApi(string userId, string id) returns error? {
    do {
        sql:ExecutionResult result = check database:apiHealthDB->execute(
            `DELETE FROM api WHERE api_id = ${id} AND user_id = ${userId}`);

        if result.affectedRowCount == 0 {
            return error(string `API with the id: ${id} not found`);
        }

    } on fail error err {
        io:println("Failed to delete API: ", err.message());
        return err;
    }
}