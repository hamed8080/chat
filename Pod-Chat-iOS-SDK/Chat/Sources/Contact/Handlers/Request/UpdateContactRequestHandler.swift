//
//  UpdateContactRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import Contacts
import Alamofire

class UpdateContactRequestHandler {
	
    class func handle(_ req:UpdateContactRequest,
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<[Contact]>,
                      _ uniqueIdResult:UniqueIdResultType = nil){
		
		guard let config = chat.config else {return}
		let url = "\(config.platformHost)\(Routes.UPDATE_CONTACTS.rawValue)"
		let headers: HTTPHeaders = ["_token_": config.token, "_token_issuer_": "1"]
		chat.restApiRequest(req, decodeType: ContactResponse.self, url: url,bodyParameter: true, method: .post ,headers: headers , uniqueIdResult: uniqueIdResult){ response in
            let contactResponse = response.result as? ContactResponse
			insertOrUpdateCache(chat: chat, contactsResponse: contactResponse)
            completion(contactResponse?.contacts ,response.uniqueId , response.error)
		}
	}
	
	private class func insertOrUpdateCache(chat:Chat , contactsResponse:ContactResponse?){
		if let contacts = contactsResponse?.contacts {
			CMContact.insertOrUpdate(contacts: contacts)
		}
		PSM.shared.save()
	}
	
}
