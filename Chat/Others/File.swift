////
////  File.swift
////  Chat
////
////  Created by Mahyar Zhiani on 6/31/1397 AP.
////  Copyright © 1397 Mahyar Zhiani. All rights reserved.
////
//
//import Foundation
//import SwiftyJSON
//
//
//open class GetThreadsCallbacks: CallbackProtocol {
//    var sendParams: JSON
//    public init(parameters: JSON) {
//        self.sendParams = parameters
//    }
//    open func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
////        print("\n On Chat")
////        print(":: \t ThreadCallback \n")
////        /*
////         + response:
////         - hasError      Bool
////         - errorMessage  String
////         - errorCode     Int
////         - result        JSON
////         - contentCount  Int
////         */
////        var returnData: JSON = [:]
////
////        let hasError = response["hasError"].boolValue
////        let errorMessage = response["errorMessage"].stringValue
////        let errorCode = response["errorCode"].intValue
////
////        returnData["hasError"] = JSON(hasError)
////        returnData["errorMessage"] = JSON(errorMessage)
////        returnData["errorCode"] = JSON(errorCode)
////
////        if (!hasError) {
////            let content = sendParams["content"]
////            let count = content["count"].intValue
////            let offset = content["offset"].intValue
////
////            let messageContent: [JSON] = response["result"].arrayValue
////            let messageLength = messageContent.count
////
////            var hasNext = false
////            let x: Int = count + offset
////            if (x < response["contentCount"].intValue) && (messageLength > 0) {
////                hasNext = true
////            }
////
////            let nextOffset: Int = offset + messageLength
////
////            var threads: [JSON] = []
////            for item in messageContent {
////                threads.append(item)
////            }
////
////            let resultData: JSON = ["threads": threads,
////                                    "contentCount": response["contentCount"].intValue,
////                                    "hasNext": hasNext,
////                                    "nextOffset": nextOffset]
////
////            returnData["result"] = resultData
////            success(returnData)
////        }
//    }
//
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//    // How to use it
////    class sasdf: GetThreadsCallbacks {
////
////        override init(parameters: JSON) {
////            super.init(parameters: parameters)
////            print("OOOOOOKKKKKKKKKKKKKKK")
////        }
////
////        override func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
////
////                print("\n On Chat")
////                print(":: \t ThreadCallback \n")
////                /*
////                 + response:
////                 - hasError      Bool
////                 - errorMessage  String
////                 - errorCode     Int
////                 - result        JSON
////                 - contentCount  Int
////                 */
////                var returnData: JSON = [:]
////
////                let hasError = response["hasError"].boolValue
////                let errorMessage = response["errorMessage"].stringValue
////                let errorCode = response["errorCode"].intValue
////
////                returnData["hasError"] = JSON(hasError)
////                returnData["errorMessage"] = JSON(errorMessage)
////                returnData["errorCode"] = JSON(errorCode)
////
////                if (!hasError) {
////                    let content = parameters["content"]
////                    let count = content["count"].intValue
////                    let offset = content["offset"].intValue
////
////                    let messageContent: [JSON] = response["result"].arrayValue
////                    let messageLength = messageContent.count
////
////                    var hasNext = false
////                    let x: Int = count + offset
////                    if (x < response["contentCount"].intValue) && (messageLength > 0) {
////                        hasNext = true
////                    }
////
////                    let nextOffset: Int = offset + messageLength
////
////                    var threads: [JSON] = []
////                    for item in messageContent {
////                        threads.append(item)
////                    }
////
////                    let resultData: JSON = ["threads": threads,
////                                            "contentCount": response["contentCount"].intValue,
////                                            "hasNext": hasNext,
////                                            "nextOffset": nextOffset]
////
////                    returnData["result"] = resultData
////                    success(returnData)
////                }
////
////        }
////    }
//
//
//
