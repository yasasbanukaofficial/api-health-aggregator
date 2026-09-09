import ballerina/time;
import api_health_aggregator.common;

public function getAll() returns API[]|ApiNotFound|error {
    API[]|error apis = check getAllApi();

    if apis is error {
        ApiNotFound apinotFound = {
            body: {msg: string `Error when fetching API`, details: apis.message(), timeStamp: time:utcNow()}
        };
        return apinotFound;
    }
    return apis;
}

public function get(string id) returns API|ApiNotFound|error {
    API|error api = check getApi(id);

    if api is error {
        ApiNotFound apinotFound = {
            body: {msg: string `Error when fetching API`, details: api.message(), timeStamp: time:utcNow()}
        };
        return apinotFound;
    }
    return api;
}

public function create(ModifyAPI modifyAPI) returns API|ApiAlreadyExists|ExecutionError|error {

    if getApiByName(modifyAPI.name) is API {
        ApiAlreadyExists apiAlreadyExists = {
            body: {msg: "Error when creating API", details: string `API already exists with the name ${modifyAPI.name}`, timeStamp: time:utcNow()}
        };
        return apiAlreadyExists;
    }

    string newId = common:generateUUID();

    API|error newApi = check createApi(newId, modifyAPI);

    if newApi is error {
        ExecutionError executionError = {
            body: {msg: "Error when creating API", details: newApi.message(), timeStamp: time:utcNow()}
        };
        return executionError;
    }

    return newApi;

}

public function update(string id, ModifyAPI modifyAPI) returns API|ApiNotFound|ExecutionError|error {
    API|error updatedApi = check updateApi(id, modifyAPI);

    if updatedApi is error {
        if updatedApi.message().includes("not found") {
            ApiNotFound apinotFound = {
                body: {msg: "Error when updating API", details: updatedApi.message(), timeStamp: time:utcNow()}
            };
            return apinotFound;
        }
        ExecutionError executionError = {
            body: {msg: "Error when updating API", details: updatedApi.message(), timeStamp: time:utcNow()}
        };
        return executionError;
    }

    return updatedApi;
}

public function delete(string id) returns common:DeletedResponse|ApiNotFound|ExecutionError|error {
    error? result = check deleteApi(id);

    if result is error {
        if result.message().includes("not found") {
            ApiNotFound apinotFound = {
                body: {msg: "Error when deleting API", details: result.message(), timeStamp: time:utcNow()}
            };
            return apinotFound;
        }
        ExecutionError executionError = {
            body: {msg: "Error when deleting API", details: result.message(), timeStamp: time:utcNow()}
        };
        return executionError;
    }

    common:DeletedResponse deleted = {
        body: "API deleted successfully"
    };
    return deleted;
}