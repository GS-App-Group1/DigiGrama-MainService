isolated function validateGSDivision(string gsDivision) returns error? {
    if (gsDivision == "") {
        return error("GS Division cannot be empty");
    }
    return null;
}

isolated function validateNotEmpty(string value) returns error? {
    if (value == "") {
        return error("ID cannot be empty");
    }
    return null;
}

isolated function validateNIC(string nic) returns true|error {
    if (nic == "") {
        return error("NIC cannot be empty");
    }

    if (nic.length() < 10 || nic.length() > 12) {
        return error("Invalid NIC");
    }

    return true;
}

isolated function validateEmail(string email) returns error? {
    if (email == "") {
        return error("Email cannot be empty");
    }

    if (email.length() < 5 || email.length() > 50) {
        return error("Invalid Email");
    }

    return null;
}

isolated function validateStatus(string status) returns error? {
    if (status == "") {
        return error("Status cannot be empty");
    }

    if (status != "approved" && status != "rejected") {
        return error("Invalid Status");
    }
    return null;
}

isolated function validateCivilStatus(string civilStatus) returns error? {
    if (civilStatus == "") {
        return error("Civil Status cannot be empty");
    }

    if (civilStatus != "married" && civilStatus != "unmarried" && civilStatus != "divorced") {
        return error("Invalid Civil Status");
    }
    return null;
}
