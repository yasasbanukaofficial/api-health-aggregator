import ballerinax/mysql;
import ballerinax/mysql.driver as _;

public type DBConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
|};

configurable DBConfig dbConfig = ?;
public final mysql:Client apiHealthDB = check initApiDb();
public function initApiDb() returns mysql:Client|error => check new(...dbConfig);

