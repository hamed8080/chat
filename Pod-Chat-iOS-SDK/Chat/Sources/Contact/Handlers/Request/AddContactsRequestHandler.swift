//
//  AddContactsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

class AddContactsRequestHandler{
    
    class func handle(_ req:[AddContactRequest],
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<[Contact]>,
                      _ uniqueIdsResult:UniqueIdsResultType = nil
                      ){
        let emails           = req.map({$0.email})
        let firstNames       = req.map({$0.firstName})
        let lastNames        = req.map({$0.lastName})
        let cellPhoneNumbers = req.map({$0.cellphoneNumber})
        let userNames        = req.map({$0.username})
        let uniqueIds        = req.map({$0.uniqueId})
        let batchAddReq = BatchAddContactsRequest(firstNameList: firstNames,
                                                  lastNameList: lastNames,
                                                  cellphoneNumberList: cellPhoneNumbers,
                                                  emailList: emails,
                                                  userNameList: userNames,
                                                  uniqueIdList: uniqueIds)
        let clientUniueId = UUID().uuidString
        chat.prepareToSendAsync(req: batchAddReq,
                                clientSpecificUniqueId: clientUniueId,
                                messageType: .ADD_CONTACT,
                                uniqueIdResult: nil){ response in
            let contactResponse = response.result as? ContactResponse
            completion(contactResponse?.contacts , response.uniqueId, response.error)
        }
    }
    
    class func addToCacheIfEnabled(chat:Chat , contacts:[Contact]?){
        if chat.config?.enableCache == true , let contacts = contacts{
            CMContact.insertOrUpdate(contacts: contacts)
        }
    }
}


