//
//  LogoutRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/4/21.
//

import Foundation
class SetRoleRequestHandler{
    
    class func handle(_ chat:Chat,
                      _ request:RolesRequest,
                      _ completion:@escaping CompletionType<[UserRole]>,
                      _ uniqueIdResult:UniqueIdResultType){
        chat.prepareToSendAsync(req: request.userRoles,
                                clientSpecificUniqueId: request.uniqueId,
                                subjectId:request.threadId,
                                messageType: .SET_RULE_TO_USER,
                                uniqueIdResult:uniqueIdResult
                                
        ){ response in
            completion(response.result as? [UserRole] , response.uniqueId , response.error)
        }
    }
}
