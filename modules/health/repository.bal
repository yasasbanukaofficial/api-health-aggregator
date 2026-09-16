import ballerina/sql;
import api_health_aggregator.common;
import api_health_aggregator.database;
import ballerina/time;

transactional isolated function addSeedHealthData(string apiId, string apiHealthId) returns error? {
    do {
        sql:ExecutionResult rslt = check database:apiHealthDB->execute(
            `INSERT INTO api_health
            VALUES (${apiHealthId}, 'UNKNOWN', null, null, ${time:utcNow()}, ${apiHealthId})`
        );

        if rslt.affectedRowCount == 0 {
            return error("Failed to insert seed health data");
        }
        
    } on fail error err {
        common:logError("Failed to create API Health: " + err.message());
        return err;
    }
}