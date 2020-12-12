// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/log;
import ballerina/test;
import ballerina/tcp;


@test:Config {
    dependsOn: ["testInvalidAddress"]
}
public isolated function testPartialRead() {
    tcp:Client socketClient = new ({host: "localhost", port: PORT2});
    string msg1 = "Hello";
    string msg2 = "from";
    string msg3 = "client";
    var writeResult = socketClient->write(msg1.toBytes());
    writeResult = socketClient->write(msg2.toBytes());
    writeResult = socketClient->write(msg3.toBytes());
    if (writeResult is int) {
        log:print("Number of bytes written: " + writeResult.toString());
    } else {
        test:assertFail(msg = writeResult.message());
    }
    var readResult = readClientMessage(socketClient);
    // TODO uncomment when non-isolated functions are possible to call from isolated functions
    //test:assertEquals(getTotalLength(), 15, msg = "Server didn't receive the expected bytes");
    closeClientConnection(socketClient);
}

@test:Config {
    dependsOn: ["testPartialRead"]
}
public isolated function testBlockingRead() {
    tcp:Client socketClient = new ({host: "localhost", port: PORT3});
    string msg1 = "ThisIs";
    string msg2 = "BlockingRead";
    var writeResult = socketClient->write(msg1.toBytes());
    writeResult = socketClient->write(msg2.toBytes());
    if (writeResult is int) {
        log:print("Number of bytes written: " + writeResult.toString());
    } else {
        test:assertFail(msg = writeResult.message());
    }

    var readResult = readClientMessage(socketClient);
    if (readResult is string) {
        // TODO uncomment when non-isolated functions are possible to call from isolated functions
        //test:assertEquals(readResult, msg1 + msg2, msg = "Found unexpected output");
    } else {
        test:assertFail(msg = readResult.message());
    }
    closeClientConnection(socketClient);
}

@test:Config {
    dependsOn: ["testBlockingRead"]
}
isolated function testSocketServerJoinLeave() {
    int i = 0;
    while(i < 5) {
        passMessageToSocketServer("Hello Ballerina\n", PORT4);
        i += 1;
    }
}

@test:Config {
    dependsOn: ["testSocketServerJoinLeave"]
}
isolated function testSocketReadTimeout() {
   passMessageToSocketServer("Hello Ballerina", PORT5);
}

isolated function passMessageToSocketServer(string msg, int port) {
    tcp:Client socketClient = new ({host: "localhost", port: port});
    byte[] msgByteArray = msg.toBytes();
    var writeResult = socketClient->write(msgByteArray);
    if (writeResult is int) {
        log:print("Number of bytes written: " + writeResult.toString());
    } else {
        test:assertFail(msg = writeResult.message());
    }
    closeClientConnection(socketClient);
}
