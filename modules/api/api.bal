import ballerina/http;
import ballerina/time;
import api_health_aggregator.common;
import api_health_aggregator.utils;

public function getAll(string userId) returns API[]|ApiError|error {
    API[]|error apis = getAllApi(userId);

    if apis is error {
        return apiError(http:STATUS_NOT_FOUND, "Error when fetching API", apis.message());
    }
    return apis;
}

public function get(string userId, string apiId) returns API|ApiError|error {
    API|error api = getApi(userId, apiId);

    if api is error {
        return apiError(http:STATUS_NOT_FOUND, "Error when fetching API", api.message());
    }
    return api;
}

public function create(string userId, ModifyAPI modifyAPI) returns API|ApiError|error {

    if getApiByName(modifyAPI.name) is API {
        return apiError(http:STATUS_CONFLICT, "Error when creating API", string `API already exists with the name ${modifyAPI.name}`);
    }

    string newId = utils:generateUUID();

    error? apiCreateError = createApi(newId, userId, modifyAPI);

    if apiCreateError is error {
        return apiError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when creating API", apiCreateError.message());
    }

    return {
        apiId: newId,
        createdTime: time:utcToCivil(time:utcNow()),
        name: modifyAPI.name,
        apiURL: modifyAPI.apiURL,
        userId
    };
}

public function update(string userId, string id, ModifyAPI modifyAPI) returns API|ApiError|error {
    API|error updatedApi = updateApi(userId, id, modifyAPI);

    if updatedApi is error {
        if updatedApi.message().includes("not found") {
            return apiError(http:STATUS_NOT_FOUND, "Error when updating API", updatedApi.message());
        }
        return apiError(http:STATUS_INTERNAL_SERVER_ERROR, "Error when updating API", updatedApi.message());
    }

    return updatedApi;
}

public function delete(string userId, string id) returns common:DeletedResponse|ApiError|error {
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