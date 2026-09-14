import ballerina/time;
import api_health_aggregator.common;
import api_health_aggregator.utils;

public function getAll(string userId) returns API[]|ApiError|error {
    API[]|error apis = getAllApi(userId);

    if apis is error {
        return <ApiNotFound>{
            body: {msg: "Error when fetching API", details: apis.message(), timeStamp: time:utcNow()}
        };
    }
    return apis;
}

public function get(string userId, string apiId) returns API|ApiError|error {
    API|error api = getApi(userId, apiId);

    if api is error {
        return <ApiNotFound>{
            body: {msg: "Error when fetching API", details: api.message(), timeStamp: time:utcNow()}
        };
    }
    return api;
}

public function create(string userId, ModifyAPI modifyAPI) returns API|ApiError|error {

    if getApiByName(modifyAPI.name) is API {
        return <ApiAlreadyExists>{
            body: {msg: "Error when creating API", details: string `API already exists with the name ${modifyAPI.name}`, timeStamp: time:utcNow()}
        };
    }

    string newId = utils:generateUUID();

    error? apiCreateError = createApi(newId, userId, modifyAPI);

    if apiCreateError is error {
        return <ExecutionError>{
            body: {msg: "Error when creating API", details: apiCreateError.message(), timeStamp: time:utcNow()}
        };
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
            return <ApiNotFound>{
                body: {msg: "Error when updating API", details: updatedApi.message(), timeStamp: time:utcNow()}
            };
        }
        return <ExecutionError>{
            body: {msg: "Error when updating API", details: updatedApi.message(), timeStamp: time:utcNow()}
        };
    }

    return updatedApi;
}

public function delete(string userId, string id) returns common:DeletedResponse|ApiError|error {
    error? result = deleteApi(userId, id);

    if result is error {
        if result.message().includes("not found") {
            return <ApiNotFound>{
                body: {msg: "Error when deleting API", details: result.message(), timeStamp: time:utcNow()}
            };
        }
        return <ExecutionError>{
            body: {msg: "Error when deleting API", details: result.message(), timeStamp: time:utcNow()}
        };
    }

    return <common:DeletedResponse>{
        body: {
            msg: "API deleted successfully",
            timeStamp: time:utcNow()
        }
    };
}