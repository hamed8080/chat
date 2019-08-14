////
////  GetAdminListCallback.swift
////  FanapPodChatSDK
////
////  Created by Mahyar Zhiani on 3/18/1398 AP.
////  Copyright © 1398 Mahyar Zhiani. All rights reserved.
////
//
//import Foundation
//import SwiftyJSON
//import SwiftyBeaver
//import FanapPodAsyncSDK
//
//
//extension Chat {
//
//    public class GetAdminListCallback: CallbackProtocol {
//        var mySendMessageParams: JSON
//        init(parameters: JSON) {
//            self.mySendMessageParams = parameters
//        }
//        func onResultCallback(uID:      String,
//                              response: JSON,
//                              success:  @escaping callbackTypeAlias,
//                              failure:  @escaping callbackTypeAlias) {
//            log.verbose("GetAdminListCallback", context: "Chat")
//
//            print("\n\n\n\n\n\n\n GetAdminListCallback response = \(response)\n\n\n\n\n\n ")
//
//            let hasError = response["hasError"].boolValue
//
//            if (!hasError) {
//                success(response)
//            }
//        }
//
//    }
//    
//}
