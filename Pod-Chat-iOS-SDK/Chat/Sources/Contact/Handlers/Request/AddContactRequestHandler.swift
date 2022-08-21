//
//  AddContactRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

class AddContactRequestHandler{
    
    class func handle(_ req:AddContactRequest,
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<[Contact]>,
                      _ uniqueIdResult:UniqueIdResultType = nil){

        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .ADD_CONTACT,
                                uniqueIdResult: uniqueIdResult){response in
            let contactResponse = response.result as? ContactResponse
            completion(contactResponse?.contacts , response.uniqueId, response.error)
        }
    }
    
    class func addToCacheIfEnabled(chat:Chat , contactsResponse:ContactResponse?){
        if chat.config?.enableCache  == true , let contacts = contactsResponse?.contacts{
            CMContact.insertOrUpdate(contacts: contacts)
        }
    }
}
