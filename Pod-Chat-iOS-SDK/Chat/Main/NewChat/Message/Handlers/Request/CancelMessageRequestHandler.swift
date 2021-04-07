//
//  CancelMessageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/6/21.
//

import Foundation
class CancelMessageRequestHandler {
    
    class func handle(_ chat:Chat,_ request:NewCancelMessageRequest, _ completion:@escaping CompletionType<Bool>){
        if chat.createChatModel?.enableCache == true {
            if let uniqueId = request.textMessageUniqueId{
                CacheFactory.write(cacheType: .DELETE_WAIT_TEXT_MESSAGE(uniqueId))
                completion(true , uniqueId , nil)
            }else if let uniqueId = request.editMessageUniqueId {
                CacheFactory.write(cacheType: .DELETE_EDIT_TEXT_MESSAGE(uniqueId))
                completion(true , uniqueId , nil)
            }else if let uniqueId = request.forwardMessageUniqueId{
                CacheFactory.write(cacheType: .DELETE_FORWARD_MESSAGE(uniqueId))
                completion(true , uniqueId , nil)
            }else if let uniqueId = request.fileMessageUniqueId{
                CacheFactory.write(cacheType: .DELETE_WAIT_FILE_MESSAGE(uniqueId))
                completion(true , uniqueId , nil)
            }else if let uniqueId = request.uploadFileUniqueId{
                chat.manageUpload(uniqueId: uniqueId, action: .cancel, isImage: false){ description,state in
                    completion(state , uniqueId , nil)
                }
            }else if let uniqueId = request.uploadImageUniqueId{
                chat.manageUpload(uniqueId: uniqueId, action: .cancel, isImage: true){ description,state in
                    completion(state , uniqueId , nil)
                }
            }
        }
    }
}
