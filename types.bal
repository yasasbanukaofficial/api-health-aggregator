import ballerina/time;
type API record {|
    readonly string apiId;
    string name;
    string apiURL;
    APIHealth health;
|};

type APIHealth record {|
    readonly string apiHealthId;
    string status;
    int responseTime;
    time:Date checkedAt;
    API apiService;
|};