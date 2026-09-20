import ballerina/log;
import ballerina/sql;
import api_health_aggregator.database;
import ballerina/time;

isolated function insertHealthRecord(APIHealth apiHealth) returns error? {
    do {
        sql:ExecutionResult rslt = check database:apiHealthDB->execute(
            `INSERT INTO api_health
            VALUES (${apiHealth.apiHealthId},
                    ${apiHealth.status},
                    ${apiHealth.statusCode},
                    ${apiHealth.responseTime}, 
                    ${apiHealth.checkedAt},
                    ${apiHealth.apiId})`
        );

        if rslt.affectedRowCount == 0 {
            return error("Failed to insert seed health data");
        }
        
    } on fail error err {
        log:printError("Failed to create API Health: " + err.message());
        return err;
    }
}

isolated function bulkInsertHealthRecords(APIHealth[] apiHealthList) returns error? {
    sql:ParameterizedQuery[] insertQueries = from APIHealth apiHealth in apiHealthList
        select `INSERT INTO api_health
                VALUES (${apiHealth.apiHealthId},
                        ${apiHealth.status},
                        ${apiHealth.statusCode},
                        ${apiHealth.responseTime}, 
                        ${apiHealth.checkedAt},
                        ${apiHealth.apiId})`;

    _ = check database:apiHealthDB->batchExecute(insertQueries);
}

transactional isolated function addSeedHealthData(string apiHealthId, string apiId) returns error? {
    do {
        sql:ExecutionResult rslt = check database:apiHealthDB->execute(
            `INSERT INTO api_health
            VALUES (${apiHealthId},
                    'UNKNOWN', 
                    null, 
                    null, 
                    ${time:utcNow()}, 
                    ${apiId})`
        );

        if rslt.affectedRowCount == 0 {
            return error("Failed to insert seed health data");
        }
        
    } on fail error err {
        log:printError("Failed to create API Health: " + err.message());
        return err;
    }
}