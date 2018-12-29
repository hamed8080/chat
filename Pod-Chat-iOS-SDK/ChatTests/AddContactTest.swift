//
//  AddContactTest.swift
//  ChatTests
//
//  Created by Mahyar Zhiani on 7/21/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON
import Async
import SwiftyBeaver
import XCTest
@testable import Chat


class SpyDelegateAddContact: ChatDelegates {

    var somethingWithDelegateAsyncResult: Bool? = .none
    var asyncExpectation: XCTestExpectation?

    func chatConnected() {}
    func chatDisconnect() {}
    func chatReconnect() {}
    func messageEvents(type: String, result: JSON) {}
    func chatDeliver(messageId: Int, ownerId: Int) {}
    func chatThreadEvents() {}
    func chatReady() {
        guard let _ = asyncExpectation else {
            XCTFail("SpyDelegateAddContact was not setup correctly. Missing XCTExpectation reference")
            return
        }

        log.debug("Test Response: \n|| Chat is Ready")

    }
    func chatError(errorCode: Int, errorMessage: String, errorResult: Any?) {}
    func chatState(state: Int) {}
    func threadEvents(type: String, result: JSON) {}
}


class AddContactsTest: XCTestCase {

    var somethingWithDelegateAsyncResult: Bool? = .none
    var myChatObject: Chat?

    // SandBox Addresses:
    let socketAddress           = "wss://chat-sandbox.pod.land/ws"
    let serverName              = "chat-server"
    let ssoHost                 = "https://accounts.pod.land"
    let platformHost            = "https://sandbox.pod.land:8043/srv/basic-platform"    // {**REQUIRED**} Platform Core Address
    let fileServer              = "http://sandbox.fanapium.com:8080"                    // {**REQUIRED**} File Server Address
    let token                   = "49f6f780e793481c83205c283751e5e5"

    // Local Addresses
    //    let socketAddress           = "ws://172.16.106.26:8003/ws"
    //    let serverName              = "chat-server"
    //    let ssoHost                 = "http://172.16.110.76"
    //    let platformHost            = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} Platform Core Address
    //    let fileServer              = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} File Server Address
    //    let token                   = "62e07ed1de2d48ab93575bd873f6a51d"
    //    let token                   = "7a18deb4a4b64339a81056089f5e5922"    // ialexi
    //    let token                   = "6421ecebd40b4d09923bcf6379663d87"    // iFelfeli
    //    let token                   = "6421ecebd40b4d09923bcf6379663d87"
    //    let token = "fbd4ecedb898426394646e65c6b1d5d1" //  {**REQUIRED**} SSO Token JiJi
    //    let token = "5fb88da4c6914d07a501a76d68a62363" // {**REQUIRED**} SSO Token FiFi
    //    let token = "bebc31c4ead6458c90b607496dae25c6" // {**REQUIRED**} SSO Token Alexi
    //    let token = "e4f1d5da7b254d9381d0487387eabb0a" // {**REQUIRED**} SSO Token Felfeli

    let wsConnectionWaitTime    = 1                 // Time out to wait for socket to get ready after open
    let connectionRetryInterval = 5                 // Time interval to retry registering device or registering server
    let connectionCheckTimeout  = 10                // Socket connection live time on server
    let messageTtl              = 86400             // Message time to live
    let reconnectOnClose        = true              // auto connect to socket after socket close


    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    // MARK: - test with params: ["firstName": "Leornardo", "lastName": "DiCaprio", "cellphoneNumber": "0913", "email": "Leornardo@DiCaprio.com"]
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    func test_Add_Contact_With() {
        myChatObject = Chat(socketAddress: socketAddress, ssoHost: ssoHost, platformHost: platformHost, fileServer: fileServer, serverName: serverName, token: token, typeCode: 1, msgPriority: 1, msgTTL: messageTtl, httpRequestTimeout: nil, actualTimingLog: nil, wsConnectionWaitTime: Double(wsConnectionWaitTime), connectionRetryInterval: connectionRetryInterval, connectionCheckTimeout: connectionCheckTimeout, messageTtl: messageTtl, reconnectOnClose: true)

        let spyDelegate = SpyDelegateAddContact()
        myChatObject?.delegate = spyDelegate

        let theExpectation = expectation(description: "Chat calls the delegate as the result of an async method completion")
        theExpectation.isInverted = true
        spyDelegate.asyncExpectation = theExpectation

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            let myExpectation = self.expectation(description: "Add Contact")
            let addContactsParams: JSON = ["firstName": "Leornardo",
                                           "lastName": "DiCaprio",
                                           "cellphoneNumber": "0913",
                                           "email": "Leornardo@DiCaprio.com"]

            self.myChatObject?.addContact(params: addContactsParams, uniqueId: { (addContactUniqueId) in
                log.debug("Add Contact with params: (firstName: Leornardo, lastName: DiCaprio, cellphoneNumber: 0913, email: Leornardo@DiCaprio.com) Unique Id Response: \n|| \(addContactUniqueId)", context: "Test")
            }, completion: { (responseJSON) in
                log.debug("Add Contact with params: (firstName: Leornardo, lastName: DiCaprio, cellphoneNumber: 0913, email: Leornardo@DiCaprio.com) Test Response: \n|| \(responseJSON)", context: "Test")
                self.somethingWithDelegateAsyncResult = true
                myExpectation.fulfill()
            })

            self.waitForExpectations(timeout: 15) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                }
                guard let result = self.somethingWithDelegateAsyncResult else {
                    XCTFail("Expected delegate to be called")
                    return
                }
                XCTAssertTrue(result)
            }

        }

    }

}



















