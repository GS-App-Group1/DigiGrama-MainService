import ballerina/http;
import ballerinax/mongodb;

type UserRequest record {|
    string _id;
    string nic;
    string name;
    string requestTime;
    boolean isApproved;
|};

# Configurations for the MongoDB endpoint
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string collection = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service /main on new http:Listener(9090) {
    final mongodb:Client databaseClient;

    public function init() returns error? {
        self.databaseClient = check new ({connection: {url: string `mongodb+srv://${username}:${password}@digigrama.pgauwpq.mongodb.net/`}});
    }

    resource function post userRequest(UserRequest userRequest) returns error? {
        _ = check self.databaseClient->insert(userRequest, collection, database);
    }

    resource function get getUserRequests() returns UserRequest[]|error? {
        stream<UserRequest, error?>|mongodb:Error UserRequestStream = check self.databaseClient->find(collection, database);
        return from UserRequest userRequest in check UserRequestStream
            select userRequest;
    }

    resource function put updateRequestStatus(int nic) returns error? {
        stream<UserRequest, error?>|mongodb:Error UserRequestStream = check self.databaseClient->find(collection, database, {nic: nic});
        UserRequest[]|error userRequests = from UserRequest userRequest in check UserRequestStream
            select userRequest;

        if (userRequests is UserRequest[]) {
            UserRequest userRequest = userRequests[0];
            userRequest.isApproved = true;
            _ = check self.databaseClient->update(userRequest, collection, database, {nic: nic});
        }
    }

    resource function get liveness() returns http:Ok {
        return http:OK;
    }

    resource function get readiness() returns http:Ok|error {
        int _ = check self.databaseClient->countDocuments(collection, database);
        return http:OK;
    }
}
