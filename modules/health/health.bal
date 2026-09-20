import ballerina/http;
import ballerina/log;
import ballerina/time;

import api_health_aggregator.utils;

public isolated function getAllHealth(HealthTarget[] targets) returns APIHealth[]|ApiHealthError {
    future<APIHealth>[] futures = [];
    foreach HealthTarget t in targets {
        future<APIHealth> f = start checkHealth(t.apiId, t.apiName, t.apiURL);
        futures.push(f);
    }

    APIHealth[] results = [];
    foreach var f in futures {
        APIHealth|error r = wait f;
        if r is APIHealth {
            results.push(r);
        } else {
            log:printError("Unable to check API health", r);
        }
    }

    error? insertError = bulkInsertHealthRecords(results.cloneReadOnly());
    if insertError is error {
        log:printError("Unable to bulk insert health records", insertError);
    }

    return results;
}

public isolated function getHealth(string apiId, string apiName, string apiUrl) returns APIHealth|ApiHealthError {
    APIHealth|error result = checkHealth(apiId, apiName, apiUrl);
    if result is error {
        return healthError(500, "Unable to check API health", result.message());
    }
    future<error?> _ = start insertHealthRecord(result.cloneReadOnly());
    return result;
}

public transactional isolated function seedHealthCheck(string apiId, string apiURL) returns error? {
    check addSeedHealthData(utils:generateUUID(), apiId);
}

isolated function checkHealth(string apiId, string apiName, string apiUrl) returns APIHealth {
    do {
        final http:Client apiClient = check new(apiUrl, {
            timeout: 3
        });

        string status = "ERROR";
        int statusCode = 404;

        time:Utc startingTime =  time:utcNow();
        http:Response|error resp = apiClient->get("");
        time:Utc endingTime =  time:utcNow();

        time:Seconds responseTime = time:utcDiffSeconds(endingTime, startingTime);
        
        if resp is error {
            status = "ERROR OCCURREDD";
            statusCode = 0;
        } else if resp.statusCode >= 200 && resp.statusCode <= 299 {
            status = "UP";
            statusCode = resp.statusCode;
        } else {
            status = "DOWN";
            statusCode = resp.statusCode;
        }

        return <APIHealth> {
            apiHealthId: utils:generateUUID(),
            apiName,
            status,
            statusCode,
            responseTime,
            checkedAt: time:utcNow(),
            apiId
        };
    } on fail {
        return <APIHealth> {
            apiHealthId: utils:generateUUID(),
            apiName,
            status: "ERROR OCCURREDD",
            statusCode: 0,
            responseTime: 0,
            checkedAt: time:utcNow(),
            apiId
        };
    }
}
