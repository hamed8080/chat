//
//  BlockCallbacks.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    /// Block Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to block function (by using "blockUserCallbackToUser")
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    func responseOfBlock(withMessage message: ChatMessage) {
        log.verbose("Message of type 'BLOCK' recieved", context: "Chat")
        
        if let contentAsJSON = message.content?.convertToJSON() {
            let blockModel = BlockedUser(messageContent: contentAsJSON)
            let blockEM = UserEventModel(type: UserEventTypes.BLOCK, blockModel: blockModel, threadId: message.subjectId)
            delegate?.userEvents(model: blockEM)
        }
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if (Chat.map[message.uniqueId] != nil) {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.blockCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
            
        } else if (Chat.spamMap[message.uniqueId] != nil) {
            let callback: CallbackProtocol = Chat.spamMap[message.uniqueId]!.first!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                                        self.spamPvThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.spamMap[message.uniqueId]?.removeFirst()
            if (Chat.spamMap[message.uniqueId]!.count < 1) {
                Chat.spamMap.removeValue(forKey: message.uniqueId)
            }
        }
        
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public class BlockCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("BlockCallback", context: "Chat")
            
            if let content = response.result {
                let blockUserModel = BlockUnblockResponse(messageContent:   content,
                                                          hasError:         response.hasError,
                                                          errorMessage:     response.errorMessage,
                                                          errorCode:        response.errorCode)
                success(blockUserModel)
            }
        }
        
    }
    
}
