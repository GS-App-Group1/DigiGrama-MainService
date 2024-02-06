import ballerina/http;
import ballerinax/mongodb;

type UserRequest record {|
    string _id;
    string nic;
    string email;
    string address;
    string civilStatus;
    string presentOccupation;
    string reason;
    string gsNote;
    string gsDivision;
    string requestTime;
    string status;
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

    resource function post userRequest(@http:Payload json payload) returns error? {
        UserRequest userRequest = check payload.cloneWithType(UserRequest);
        _ = check self.databaseClient->insert(userRequest, collection, database);
    }

    resource function get getUserRequests(string gsDivision) returns json|error? {
        _ = check validateGSDivision(gsDivision);
        stream<UserRequest, error?>|mongodb:Error UserRequestStream = check self.databaseClient->find(collection, database, {gsDivision: gsDivision});
        UserRequest[]|error userRequests = from UserRequest userRequest in check UserRequestStream
            select userRequest;

        return (check userRequests).toJson();
    }

    resource function get getUserRequestByID(string id) returns json|error? {
        _ = check validateNotEmpty(id);
        stream<UserRequest, error?>|mongodb:Error UserRequestStream = check self.databaseClient->find(collection, database, {_id: id});
        UserRequest[]|error userRequests = from UserRequest userRequest in check UserRequestStream
            select userRequest;

        return (check userRequests).toJson();
    }

    resource function get getUserRequestForNIC(string nic, string email) returns json|error? {
        _ = check validateNIC(nic);
        _ = check validateEmail(email);
        stream<UserRequest, error?>|mongodb:Error UserRequestStream = check self.databaseClient->find(collection, database, {nic: nic, email: email}, {}, {requestTime: -1}, 1);
        UserRequest[]|error userRequests = from UserRequest userRequest in check UserRequestStream
            select userRequest;

        return (check userRequests).toJson();
    }

    resource function put updateRequestStatus(string nic, string email, string status) returns error? {
        _ = check validateNIC(nic);
        _ = check validateEmail(email);
        _ = check validateStatus(status);
        stream<UserRequest, error?>|mongodb:Error UserRequestStream = check self.databaseClient->find(collection, database, {nic: nic, email: email, status: "pending"});
        UserRequest[]|error userRequests = from UserRequest userRequest in check UserRequestStream
            select userRequest;

        if (userRequests is UserRequest[]) {
            UserRequest userRequest = userRequests[0];
            userRequest.status = status;
            _ = check self.databaseClient->update({"$set": userRequest}, collection, database, {nic: nic, email: email, status: "pending"});
        }
    }

    resource function put updateUserRequest(string nic, string email, string address, string civil_status, string presentOccupation, string reason) returns error? {
        _ = check validateNIC(nic);
        _ = check validateEmail(email);
        _ = check validateNotEmpty(address);
        _ = check validateCivilStatus(civil_status);
        _ = check validateNotEmpty(presentOccupation);
        _ = check validateNotEmpty(reason);

        stream<UserRequest, error?>|mongodb:Error UserRequestStream = check self.databaseClient->find(collection, database, {nic: nic, email: email, status: "pending"});
        UserRequest[]|error userRequests = from UserRequest userRequest in check UserRequestStream
            select userRequest;

        if (userRequests is UserRequest[]) {
            UserRequest userRequest = userRequests[0];
            userRequest.nic = nic;
            userRequest.address = address;
            userRequest.civilStatus = civil_status;
            userRequest.presentOccupation = presentOccupation;
            userRequest.reason = reason;
            _ = check self.databaseClient->update({"$set": userRequest}, collection, database, {nic: nic, email: email, status: "pending"});
        }
    }

    resource function put updateGSRequest(string nic, string email, string gsNote) returns error? {
        _ = check validateNIC(nic);
        _ = check validateEmail(email);
        _ = check validateNotEmpty(gsNote);

        stream<UserRequest, error?>|mongodb:Error UserRequestStream = check self.databaseClient->find(collection, database, {nic: nic, email: email, status: "pending"});
        UserRequest[]|error userRequests = from UserRequest userRequest in check UserRequestStream
            select userRequest;

        if (userRequests is UserRequest[]) {
            UserRequest userRequest = userRequests[0];
            userRequest.gsNote = gsNote;
            _ = check self.databaseClient->update({"$set": userRequest}, collection, database, {nic: nic, email: email, status: "pending"});
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

