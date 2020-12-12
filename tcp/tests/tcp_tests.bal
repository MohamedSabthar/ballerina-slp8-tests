// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/log;
import ballerina/test;
import ballerina/tcp;


@test:Config {
}
public isolated function testOneWayWrite() {
    tcp:Client socketClient = new ({host: "localhost", port: PORT1});
    string msg = "Hello Ballerina";
    byte[] msgByteArray = msg.toBytes();
    var writeResult = socketClient->write(msgByteArray);
    if (writeResult is int) {
        log:print("Number of bytes written: " + writeResult.toString());
    } else {
        test:assertFail(msg = writeResult.message());
    }

    // TODO uncomment when non-isolated functions are possible to call from isolated functions
    //var readResult = readClientMessage(socketClient);
    //if (readResult is string) {
    //    test:assertEquals(readResult, msg, msg = "Found unexpected output");
    //} else {
    //    test:assertFail(msg = readResult.message());
    //}

    closeClientConnection(socketClient);
}

@test:Config {
    dependsOn: ["testOneWayWrite"]
}
isolated function testShutdownWrite() returns error? {
    string firstMsg = "Hello Ballerina1";
    string secondMsg = "Hello Ballerina2";
    tcp:Client socketClient = new ({host: "localhost", port: PORT1});
    byte[] msgByteArray = firstMsg.toBytes();
    var writeResult = socketClient->write(msgByteArray);
    if (writeResult is int) {
        log:print("Number of bytes written: " + writeResult.toString());
    } else {
        test:assertFail(msg = writeResult.message());
    }

    // TODO uncomment when non-isolated functions are possible to call from isolated functions
    //var readResult = readClientMessage(socketClient);
    //if (readResult is string) {
    //    test:assertEquals(readResult, firstMsg, msg = "Found unexpected output");
    //} else {
    //    test:assertFail(msg = readResult.message());
    //}

    var shutdownResult = socketClient->shutdownWrite();
    if (shutdownResult is error) {
        test:assertFail(msg = shutdownResult.message());
    }
    msgByteArray = secondMsg.toBytes();
    writeResult = socketClient->write(msgByteArray);
    if !(writeResult is error) {
        test:assertFail("Expected: Connection refused");
    }
    closeClientConnection(socketClient);

    return;
}

@test:Config {
    dependsOn: ["testShutdownWrite"]
}
isolated function testEcho() {
    tcp:Client socketClient = new ({host: "localhost", port: PORT1});
    string msg = "Hello Ballerina Echo";
    string returnStr = "";
    byte[] msgByteArray = msg.toBytes();
    var writeResult = socketClient->write(msgByteArray);
    if (writeResult is int) {
        io:println("Number of bytes written: ", writeResult);
    } else {
        test:assertFail(msg = writeResult.message());
    }
    // TODO uncomment when non-isolated functions are possible to call from isolated functions
    //var readResult = readClientMessage(socketClient);
    //if (readResult is string) {
    //    test:assertEquals(readResult, msg, msg = "Found unexpected output");
    //} else {
    //    test:assertFail(msg = readResult.message());
    //}

    closeClientConnection(socketClient);
}

@test:Config {
    dependsOn: ["testEcho"]
}
isolated function testInvalidReadParam() {
    var result = invalidReadParam();
    if (result is error) {
        log:print(result.message());
    } else {
        test:assertFail("Expected: {ballerina/socket}ReadTimedOut, not found");
    }
}

@test:Config {
    dependsOn: ["testInvalidReadParam"]
}
isolated function testInvalidAddress() {
    var result = invalidAddress();
    if (result is error) {
        log:print(result.message());
    } else {
        test:assertFail("Expected error unable to start the client socket: Connection refused, not found");
    }
}

isolated function invalidReadParam() returns @tainted [byte[], int]|error {
    tcp:Client socketClient = new ({host: "localhost", port: PORT1});
    return trap socketClient->read(0);
}

isolated function invalidAddress() returns error? {
    error? result = trap createClient();
    return result;
}

isolated function createClient() {
    tcp:Client socketClient = new ({host: "localhost", port: PORT6});
}

isolated function readClientMessage(tcp:Client socketClient) returns @tainted string|error {
    var readResult = socketClient->read();
    if (readResult is [byte[], int]) {
        var [reply, length] = readResult;
        if (length > 0) {
            // TODO uncomment when non-isolated functions are possible to call from isolated functions
            //var byteChannel = io:createReadableChannel(reply);
            //if (byteChannel is io:ReadableByteChannel) {
            //    io:ReadableCharacterChannel characterChannel = new io:ReadableCharacterChannel(byteChannel, "UTF-8");
            //    return characterChannel.read(25);
            //} else {
            //    return "tcp:Client close";
            //}
        }
    }
    return "";
}

isolated function closeClientConnection(tcp:Client socketClient) {
    var closeResult = socketClient->close();
    if (closeResult is error) {
        log:printError(closeResult.message());
    } else {
        log:print("tcp:Client connection closed successfully.");
    }
}
