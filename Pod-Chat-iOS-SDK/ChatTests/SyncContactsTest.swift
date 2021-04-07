////
////  SyncContactsTest.swift
////  ChatTests
////
////  Created by Mahyar Zhiani on 8/5/1397 AP.
////  Copyright © 1397 Mahyar Zhiani. All rights reserved.
////
//
//import Contacts
//import SwiftyJSON
//import XCTest
//@testable import FanapPodChatSDK
//
//
//class SpyDelegateSyncContact: ChatDelegates {
//
//    var somethingWithDelegateAsyncResult: Bool? = .none
//    var asyncExpectation: XCTestExpectation?
//
//    func chatConnect() {}
//    func chatReady(withUserInfo: User) {
//        guard let expectation = asyncExpectation else {
//            XCTFail("SpyDelegateGetUserInfo was not setup correctly. Missing XCTExpectation reference")
//            return
//        }
//        print("\n\n\n******************************")
//        print("Chat is Ready")
//        print("******************************\n")
//    }
//    func chatDisconnect() {}
//    func chatReconnect() {}
//    func chatState(state: Int) {}
//    func chatError(errorCode: Int, errorMessage: String, errorResult: Any?) {}
//    func contactEvents(type: ContactEventTypes, result: Any) {}
//    func threadEvents(type: ThreadEventTypes, result: Any) {}
//    func messageEvents(type: MessageEventTypes, result: Any) {}
//    func botEvents(type: BotEventTypes, result: Any) {}
//    func fileUploadEvents(type: FileUploadEventTypes, result: Any) {}
//    func systemEvents(type: SystemEventTypes, result: Any) {}
//}
//
//
//class SyncContactsTest: XCTestCase {
//
//    var somethingWithDelegateAsyncResult: Bool? = .none
//    var somethingWithDelegateAsyncResult2: Bool? = .none
////    var myChatObject =
//
//
//    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//    // MARK: - test with params: [subjectId: 1133,repliedTo: 15397,content: 'empty message']
//    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//    func test_Sync_Contact_response() {
//        let spyDelegate = SpyDelegateSyncContact()
//
//        Chat.sharedInstance.createChatObject(socketAddress:          "wss://chat-sandbox.pod.ir/ws",
//                                            ssoHost:                "https://accounts.pod.ir",
//                                            platformHost:           "https://sandbox.pod.ir:8043/srv/basic-platform",
//                                            fileServer:             "http://sandbox.fanapium.com:8080",
//                                            serverName:             "chat-server",
//                                            token:                  "4403badefc1848d6a76b70bca8d1f5b0",
//                                            mapApiKey:              nil,
//                                            mapServer:              "https://api.neshan.org/v1",
//                                            typeCode:               "default",
//                                            enableCache:            false,
//                                            cacheTimeStampInSec:    nil,
//                                            msgPriority:            1,
//                                            msgTTL:                 86400,
//                                            httpRequestTimeout:     nil,
//                                            actualTimingLog:        nil,
//                                            wsConnectionWaitTime:   Double(1),
//                                            connectionRetryInterval: 5,
//                                            connectionCheckTimeout: 10,
//                                            messageTtl:             86400,
//                                            reconnectOnClose:       true)
//
//        Chat.sharedInstance.delegate = spyDelegate
//
//        let contact = CNMutableContact()
//        contact.givenName = "Nani"
//        contact.familyName = "Bani"
////        let email: NSCopying = "miladBaghi@gmail.com" as NSCopying
////        let homeEmail = CNLabeledValue(label: CNLabelHome, value: "miladBaghi@gmail.com")
//        contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: "Nani@gmail.com")]
//        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: "09151112233"))]
//
//        let store = CNContactStore()
//        let saveRequest = CNSaveRequest()
//        saveRequest.add(contact, toContainerWithIdentifier:nil)
//        try! store.execute(saveRequest)
//
////        saveRequest.add(contact, toContainerWithIdentifier: nil)
////        try store.execute(saveRequest)
//
//
//        let theExpectation = expectation(description: "Chat calls the delegate as the result of an async method completion")
//        theExpectation.isInverted = true
//        spyDelegate.asyncExpectation = theExpectation
//
//        waitForExpectations(timeout: 8) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//
//            let myExpectation = self.expectation(description: "send message uniqueId")
//
//            Chat.sharedInstance.syncContact2(uniqueId: { (syncContactUniqueId) in
//                print("\n sync Contact request uniqueId = \t \(syncContactUniqueId) \n")
//            }, completion: { (myResponse) in
//                self.somethingWithDelegateAsyncResult = true
//                print("******************************")
//                print("******************************")
//                let myResponseModel: ContactModel = myResponse as! ContactModel
//                let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
//                print("\n this is my sync contacts response:")
//                print("\(myResponseJSON)")
//                print("******************************")
//                print("******************************")
//                myExpectation.fulfill()
//            }, cacheResponse: { _ in })
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
//        }
//
//    }
//}
