import api_health_aggregator.api;
import ballerina/http;
import ballerina/io;
import ballerina/time;

public function getAllHealth(string userId) returns APIHealth[]|api:ApiError{
    api:API[]|api:ApiError|error apiList = api:getAll(userId);
    future<APIHealth|error>[] futureApiHealthList = [];
    APIHealth[] results = [];

    if apiList is error|api:ApiError {
        return api:apiError(500, "Unable to retrieve APIs", apiList is error ? apiList.message(): apiList.body.details);
    }
    foreach api:API api in apiList {
            future<APIHealth|error> futureApiHealth = start checkHealth(api);
            futureApiHealthList.push(futureApiHealth);
        }
        foreach future<APIHealth|error> futureApi in futureApiHealthList {
            APIHealth|error apiHealth = wait futureApi;
            if apiHealth is APIHealth {
                results.push(apiHealth);
            }
        }
    return results;
}


function checkHealth(api:API api) returns APIHealth|error {
    final http:Client apiClient = check new(api.apiURL, {
        timeout: 3
    });

    string status = "ERROR";
    int statusCode = 404;

    time:Utc startingTime =  time:utcNow();
    http:Response|error resp = apiClient->get("/");
    time:Utc endingTime =  time:utcNow();

    time:Seconds responseTime = time:utcDiffSeconds(endingTime, startingTime);
    io:println(responseTime);
    
    if resp is error {
        status = "DOWN";
        statusCode = 404;
    } else if resp.statusCode >= 200 && resp.statusCode <= 299 {
        status = "UP";
        statusCode = resp.statusCode;
    }

    return <APIHealth> {
        apiHealthId: "",
        status,
        statusCode,
        responseTime,
        checkedAt: time:utcNow(),
        apiId: ""
    };
}