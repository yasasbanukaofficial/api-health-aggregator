import ballerina/http;
import ballerina/log;
import ballerina/time;

import api_health_aggregator.utils;

final isolated map<http:Client> clients = {};

isolated function getApiClient(string apiUrl) returns http:Client|error {
    lock{
        http:Client? existingClient = clients[apiUrl];
        if existingClient !is () {
            return existingClient;
        }
        
        http:Client newClient = check new(apiUrl, {
            timeout: 3
        });

        clients[apiUrl] = newClient;

        return newClient;
    }    
};

public isolated function getAllHealth(HealthTarget[] targets) returns APIHealthResponse[]|ApiHealthError {
    future<APIHealthResponse>[] futures = [];
    foreach HealthTarget t in targets {
        future<APIHealthResponse> f = start checkHealth(t.apiId, t.apiName, t.apiURL);
        futures.push(f);
    }

    APIHealthResponse[] results = [];
    foreach var f in futures {
        APIHealthResponse|error r = wait f;
        if r is APIHealthResponse {
            results.push(r);
        } else {
            log:printError("Unable to check API health", r);
        }
    }

    error? insertError = bulkInsertHealthRecords(from APIHealthResponse r in results select mapToApiHealth(r));
    if insertError is error {
        log:printError("Unable to bulk insert health records", insertError);
    }

    return results;
}

public isolated function getHealth(string apiId, string apiName, string apiUrl) returns APIHealthResponse|ApiHealthError {
    APIHealthResponse|error result = checkHealth(apiId, apiName, apiUrl);
    if result is error {
        return healthError(500, "Unable to check API health", result.message());
    }
    error? insertError = insertHealthRecord(mapToApiHealth(result).cloneReadOnly());
    if insertError is error {
        log:printError("Unable to insert health record", insertError);
    }
    return result;
}

public transactional isolated function seedHealthCheck(string apiId, string apiURL) returns error? {
    check addSeedHealthData(utils:generateUUID(), apiId);
}

isolated function checkHealth(string apiId, string apiName, string apiUrl) returns APIHealthResponse {
    do {
        final http:Client apiClient = check getApiClient(apiUrl);

        string status = "ERROR";
        int statusCode = 404;

        time:Utc startingTime =  time:utcNow();
        http:Response|error resp = apiClient->get("");
        time:Utc endingTime =  time:utcNow();

        time:Seconds responseTime = time:utcDiffSeconds(endingTime, startingTime);
        
        if resp is error {
            status = "ERROR OCCURRED";
            statusCode = 0;
        } else if resp.statusCode >= 200 && resp.statusCode <= 299 {
            status = "UP";
            statusCode = resp.statusCode;
        } else {
            status = "DOWN";
            statusCode = resp.statusCode;
        }

        return <APIHealthResponse> {
            apiHealthId: utils:generateUUID(),
            apiName,
            status,
            statusCode,
            responseTime,
            checkedAt: time:utcNow(),
            apiId
        };
    } on fail {
        return <APIHealthResponse> {
            apiHealthId: utils:generateUUID(),
            apiName,
            status: "ERROR OCCURRED",
            statusCode: 0,
            responseTime: 0,
            checkedAt: time:utcNow(),
            apiId
        };
    }
}

isolated function mapToApiHealth(APIHealthResponse response) returns APIHealth {
    return <APIHealth> {
        apiHealthId: response.apiHealthId,
        status: response.status,
        statusCode: response.statusCode,
        responseTime: response.responseTime,
        checkedAt: response.checkedAt,
        apiId: response.apiId
    };
}