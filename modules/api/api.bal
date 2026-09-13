import ballerina/time;
import api_health_aggregator.common;
import api_health_aggregator.utils;

public function getAll(string userId) returns API[]|ApiNotFound|error {
    API[]|error apis = getAllApi(userId);

    if apis is error {
        return <ApiNotFound>{
            body: {msg: "Error when fetching API", details: apis.message(), timeStamp: time:utcNow()}
        };
    }
    return apis;
}

public function get(string userId, string apiId) returns API|ApiNotFound|error {
    API|error api = getApi(userId, apiId);

    if api is error {
        return <ApiNotFound>{
            body: {msg: "Error when fetching API", details: api.message(), timeStamp: time:utcNow()}
        };
    }
    return api;
}

public function create(string userId, ModifyAPI modifyAPI) returns API|ApiAlreadyExists|ExecutionError|error {

    if getApiByName(modifyAPI.name) is API {
        return <ApiAlreadyExists>{
            body: {msg: "Error when creating API", details: string `API already exists with the name ${modifyAPI.name}`, timeStamp: time:utcNow()}
        };
    }

    string newId = utils:generateUUID();

    API|error newApi = createApi(newId, modifyAPI);

    if newApi is error {
        return <ExecutionError>{
            body: {msg: "Error when creating API", details: newApi.message(), timeStamp: time:utcNow()}
        };
    }

    return newApi;
}

public function update(string userId, string id, ModifyAPI modifyAPI) returns API|ApiNotFound|ExecutionError|error {
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

public function delete(string userId, string id) returns common:DeletedResponse|ApiNotFound|ExecutionError|error {
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

    return {
        body: "API deleted successfully"
    };
}