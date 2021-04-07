////
////  SpamPvThreadTest.swift
////  ChatTests
////
////  Created by Mahyar Zhiani on 8/13/1397 AP.
////  Copyright © 1397 Mahyar Zhiani. All rights reserved.
////
//
//import SwiftyJSON
//import SwiftyBeaver
//
//import FanapPodAsyncSDK
//
//import XCTest
////@testable import Chat
//@testable import FanapPodChatSDK
//
//class SpyDelegateSpamPvThread: ChatDelegates {
//    
//    var somethingWithDelegateAsyncResult: Bool? = .none
//    var asyncExpectation: XCTestExpectation?
//    
//    func chatConnected() {}
//    func chatDisconnect() {}
//    func chatReconnect() {}
//    func messageEvents(type: String, result: JSON) {}
//    func chatDeliver(messageId: Int, ownerId: Int) {}
//    func chatThreadEvents() {}
//    func chatReady() {
//        guard let _ = asyncExpectation else {
//            XCTFail("SpyDelegateSpamPvThread was not setup correctly. Missing XCTExpectation reference")
//            return
//        }
//        
//        log.debug("Test Response: \n|| Chat is Ready")
//        
//    }
//    func chatError(errorCode: Int, errorMessage: String, errorResult: Any?) {}
//    func chatState(state: Int) {}
//    func threadEvents(type: String, result: JSON) {}
//}
//
//
//class SpamPvThreadTest: XCTestCase {
//    
//    var somethingWithDelegateAsyncResult: Bool? = .none
//    var myChatObject: Chat?
//    
//    // SandBox Addresses:
//    let socketAddress           = "wss://chat-sandbox.pod.land/ws"
//    let serverName              = "chat-server"
//    let ssoHost                 = "https://accounts.pod.land"
//    let platformHost            = "https://sandbox.pod.land:8043/srv/basic-platform"    // {**REQUIRED**} Platform Core Address
//    let fileServer              = "http://sandbox.fanapium.com:8080"                    // {**REQUIRED**} File Server Address
//    let token                   = "fdc1234e27a14845bd2d79ab6fef2628"
//    
//    // Local Addresses
//    //    let socketAddress           = "ws://172.16.106.26:8003/ws"
//    //    let serverName              = "chat-server"
//    //    let ssoHost                 = "http://172.16.110.76"
//    //    let platformHost            = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} Platform Core Address
//    //    let fileServer              = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} File Server Address
//    //    let token                   = "62e07ed1de2d48ab93575bd873f6a51d"
//    //    let token                   = "7a18deb4a4b64339a81056089f5e5922"    // ialexi
//    //    let token                   = "6421ecebd40b4d09923bcf6379663d87"    // iFelfeli
//    //    let token                   = "6421ecebd40b4d09923bcf6379663d87"
//    //    let token = "fbd4ecedb898426394646e65c6b1d5d1" //  {**REQUIRED**} SSO Token JiJi
//    //    let token = "5fb88da4c6914d07a501a76d68a62363" // {**REQUIRED**} SSO Token FiFi
//    //    let token = "bebc31c4ead6458c90b607496dae25c6" // {**REQUIRED**} SSO Token Alexi
//    //    let token = "e4f1d5da7b254d9381d0487387eabb0a" // {**REQUIRED**} SSO Token Felfeli
//    
//    let wsConnectionWaitTime    = 1                 // Time out to wait for socket to get ready after open
//    let connectionRetryInterval = 5                 // Time interval to retry registering device or registering server
//    let connectionCheckTimeout  = 10                // Socket connection live time on server
//    let messageTtl              = 86400             // Message time to live
//    let reconnectOnClose        = true              // auto connect to socket after socket close
//    
//    
//    
//    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//    // MARK: - test with params: [contactId: 563]
//    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//    func test_Spam_Pv_Thread_uniqueId() {
//        myChatObject = Chat(socketAddress: socketAddress,
//                            ssoHost: ssoHost,
//                            platformHost: platformHost,
//                            fileServer: fileServer,
//                            serverName: serverName,
//                            token: token,
//                            typeCode: "chattest",
//                            enableCache: false,
//                            msgPriority: 1,
//                            msgTTL: messageTtl,
//                            httpRequestTimeout: nil,
//                            actualTimingLog: nil,
//                            wsConnectionWaitTime: Double(wsConnectionWaitTime),
//                            connectionRetryInterval: connectionRetryInterval,
//                            connectionCheckTimeout: connectionCheckTimeout,
//                            messageTtl: messageTtl,
//                            reconnectOnClose: true)
//        
//        let spyDelegate = SpyDelegateSpamPvThread()
//        myChatObject?.delegate = spyDelegate
//        
//        let theExpectation = expectation(description: "Chat calls the delegate as the result of an async method completion")
//        theExpectation.isInverted = true
//        spyDelegate.asyncExpectation = theExpectation
//        
//        waitForExpectations(timeout: 9) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//            
//            let myExpectation = self.expectation(description: "spam Pv Thread")
//            let spamPvThreadParameters: JSON = ["threadId": 1327]
//            
//            self.myChatObject?.spamPvThread(params: spamPvThreadParameters, uniqueId: { (spamPvThreadUniqueId) in
//                self.somethingWithDelegateAsyncResult = true
//                log.debug("Spam Pv Thread with params: (threadId: 1327) Unique Id Response: \n|| \(spamPvThreadUniqueId)", context: "Test")
//                myExpectation.fulfill()
//            }, completion: { (responseJSON) in
//                log.debug("Spam Pv Thread with params: (threadId: 1327) Test Response: \n|| \(responseJSON)", context: "Test")
//            })
//            
//            self.waitForExpectations(timeout: 19) { error in
//                if let error = error {
//                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//                }
//                guard let result = self.somethingWithDelegateAsyncResult else {
//                    XCTFail("Expected delegate to be called")
//                    return
//                }
//                XCTAssertTrue(result)
//            }
//            
//        }
//    }
//    
//    
//    
//    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//    // MARK: - test with params: [contactId: 563]
//    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//    func test_Spam_Pv_Thread_With_threadId_1328() {
//        myChatObject = Chat(socketAddress: socketAddress,
//                            ssoHost: ssoHost,
//                            platformHost: platformHost,
//                            fileServer: fileServer,
//                            serverName: serverName,
//                            token: token,
//                            typeCode: "chattest",
//                            enableCache: false,
//                            msgPriority: 1,
//                            msgTTL: messageTtl,
//                            httpRequestTimeout: nil,
//                            actualTimingLog: nil,
//                            wsConnectionWaitTime: Double(wsConnectionWaitTime),
//                            connectionRetryInterval: connectionRetryInterval,
//                            connectionCheckTimeout: connectionCheckTimeout,
//                            messageTtl: messageTtl,
//                            reconnectOnClose: true)
//        
//        let spyDelegate = SpyDelegateSpamPvThread()
//        myChatObject?.delegate = spyDelegate
//        
//        let theExpectation = expectation(description: "Chat calls the delegate as the result of an async method completion")
//        theExpectation.isInverted = true
//        spyDelegate.asyncExpectation = theExpectation
//        
//        waitForExpectations(timeout: 9) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//            
//            let myExpectation = self.expectation(description: "spam Pv Thread")
//            let spamPvThreadParameters: JSON = ["threadId": 1362]
//            
//            self.myChatObject?.spamPvThread(params: spamPvThreadParameters, uniqueId: { (spamPvThreadUniqueId) in
//                log.debug("Spam Pv Thread with params: (threadId: 1362) Unique Id Response: \n|| \(spamPvThreadUniqueId)", context: "Test")
//            }, completion: { (responseJSON) in
//                log.debug("Spam Pv Thread with params: (threadId: 1362) Test Response: \n|| \(responseJSON)", context: "Test")
//                self.somethingWithDelegateAsyncResult = true
//                myExpectation.fulfill()
//            })
//            
//            self.waitForExpectations(timeout: 19) { error in
//                if let error = error {
//                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//                }
//                guard let result = self.somethingWithDelegateAsyncResult else {
//                    XCTFail("Expected delegate to be called")
//                    return
//                }
//                XCTAssertTrue(result)
//            }
//            
//        }
//    }
//    
//    
//}
//
//
//
//
//
//
//
