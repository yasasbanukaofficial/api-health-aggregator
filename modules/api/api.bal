import ballerina/http;
import ballerina/time;
import api_health_aggregator.common;
import api_health_aggregator.utils;
import api_health_aggregator.health;

public isolated function getAll(string userId) returns API[]|ApiError {
    API[]|error apis = getAllApi(userId);

    if apis is error {
        return apiError(http:STATUS_NOT_FOUND, "Error when fetching API", apis.message());
    }
    return apis;
}

public isolated function get(string userId, string apiId) returns API|ApiError {
    API|error api = getApi(userId, apiId);

    if api is error {
        return apiError(http:STATUS_NOT_FOUND, "Error when fetching API", api.message());
    }
    return api;
}

public isolated function getApiUrl(string userId, string apiId) returns string|ApiError {
    string|error apiUrl = getUrlByApiId(userId, apiId);

    if apiUrl is error {
        return apiError(http:STATUS_NOT_FOUND, "Error when fetching API URL", apiUrl.message());
    }

    return apiUrl;
}



public isolated function getAllHealth(string userId) returns health:APIHealth[]|ApiError|health:ApiHealthError {
    API[]|ApiError apis = getAll(userId);
    if apis is ApiError {
        return apis;
    }
    health:HealthTarget[] targets = from var a in apis select {apiId: a.apiId, apiName: a.name, apiURL: a.apiURL};
    return health:getAllHealth(targets);
}

public isolated function getHealth(string userId, string apiId) returns health:APIHealth|ApiError|health:ApiHealthError {
    API|error existingAPI = getApi(userId, apiId);
    if existingAPI is error {
        return apiError(http:STATUS_NOT_FOUND, "Error when fetching API", existingAPI.message());
    }
    return health:getHealth(apiId, existingAPI.name, existingAPI.apiURL);
}

public isolated function create(string userId, ModifyAPI modifyAPI) returns API|ApiError {
    API|error existingAPI = getApiByUrl(userId, modifyAPI.apiURL);
    
    if existingAPI is API {
        return apiError(http:STATUS_CONFLICT, "Error when creating API", string `API already exists with the current url of ${modifyAPI.apiURL}`);
    }

    string newId = utils:generateUUID();

    error? transactionAPI = createApiAndHealth(newId, userId, modifyAPI);

    if transactionAPI is error {
        return apiError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when creating API", transactionAPI.message());
    }

    return {
        apiId: newId,
        createdTime: time:utcToCivil(time:utcNow()),
        name: modifyAPI.name,
        apiURL: modifyAPI.apiURL,
        userId
    };
}

isolated function createApiAndHealth(string newId, string userId, ModifyAPI modifyAPI) returns error? {
    transaction {
        check createApi(newId, userId, modifyAPI);
        check health:seedHealthCheck(newId, modifyAPI.apiURL);
        check commit;
    }
}

public isolated function update(string userId, string id, ModifyAPI modifyAPI) returns API|ApiError {
    API|error updatedApi = updateApi(userId, id, modifyAPI);

    if updatedApi is error {
        if updatedApi.message().includes("not found") {
            return apiError(http:STATUS_NOT_FOUND, "Error when updating API", updatedApi.message());
        }
        return apiError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when updating API", updatedApi.message());
    }

    return updatedApi;
}

public isolated function delete(string userId, string id) returns common:DeletedResponse|ApiError {
    error? result = deleteApi(userId, id);

    if result is error {
        if result.message().includes("not found") {
            return apiError(http:STATUS_NOT_FOUND, "Error when deleting API", result.message());
        }
        return apiError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when deleting API", result.message());
    }

    return <common:DeletedResponse>{
        body: {
            msg: "API deleted successfully",
            timeStamp: time:utcNow()
        }
    };
}