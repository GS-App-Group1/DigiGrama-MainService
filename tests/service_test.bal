import ballerina/http;
import ballerina/io;
import ballerina/test;

http:Client testClient = check new ("http://localhost:9090");

// Before Suite Function

@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("Running Address API Service tests...");
}

// Test function
@test:Config {}
function getUserRequestsWithProperGSDivision() returns error? {
    json|error response = check testClient->get("/main/getAddressByNIC/?gsDivision=Moratuwa");
    json[] responseJson = [{"_id": "2023-12-14T04:39:13.0jkjnkj60Z", "nic": "200005703120", "email": "themirada@wso2.com", "address": "kkkkkkkkkkkoooooooo111111133333knakwdnawd", "civilStatus": "ggggggggoqpqqqqqqqqqq22222222", "presentOccupation": "iwajdoiwjdioajdokkkkkkkkk3333333", "reason": "koakwjdija444444445555555", "gsNote": "test note bdjabwkdjbawkd sefsef", "gsDivision": "Sooriyagoda", "requestTime": "2023-12-14T04:39:13.060Z", "status": "pending"}];
    test:assertEquals(response, responseJson);
}

@test:Config {}
function getUserRequestByIDWithProperGSDivision() returns error? {
    json|error response = check testClient->get("/main/getAddressByNIC/?id=2023-12-14T04:39:13.0jkjnkj60Z");
    json[] responseJson = [{"_id": "2023-12-14T04:39:13.0jkjnkj60Z", "nic": "200005703120", "email": "themirada@wso2.com", "address": "kkkkkkkkkkkoooooooo111111133333knakwdnawd", "civilStatus": "ggggggggoqpqqqqqqqqqq22222222", "presentOccupation": "iwajdoiwjdioajdokkkkkkkkk3333333", "reason": "koakwjdija444444445555555", "gsNote": "test note bdjabwkdjbawkd sefsef", "gsDivision": "Sooriyagoda", "requestTime": "2023-12-14T04:39:13.060Z", "status": "pending"}];
    test:assertEquals(response, responseJson);
}

// Negative test function

@test:Config {}
function getUserRequestsWithNoGSDivision() returns error? {
    http:Response response = check testClient->get("/main/getUserRequests/?gsDivision=");
    test:assertEquals(response.statusCode, 500);
    json errorPayload = check response.getJsonPayload();
    test:assertEquals(errorPayload.message, "GS Division cannot be empty");
}

function getUserRequestByIDWithNoGSDivision() returns error? {
    http:Response response = check testClient->get("/main/getUserRequestByID/?id=");
    test:assertEquals(response.statusCode, 500);
    json errorPayload = check response.getJsonPayload();
    test:assertEquals(errorPayload.message, "ID cannot be empty");
}

// After Suite Function

@test:AfterSuite
function afterSuiteFunc() {
    io:println("Address API Service tests completed...");
}
