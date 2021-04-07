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
	
	class func handle( req:UpdateContactRequest , chat:Chat,typeCode:String? = nil , completion: @escaping CompletionType<[Contact]>){
		
		guard let createChatModel = chat.createChatModel else {return}
		let url = "\(createChatModel.platformHost)\(SERVICES_PATH.UPDATE_CONTACTS.rawValue)"
		let headers: HTTPHeaders = ["_token_": createChatModel.token, "_token_issuer_": "1"]
		chat.restApiRequest(req, decodeType: NewContactResponse.self, url: url, method: .post ,headers: headers , typeCode: typeCode){ response in
            let contactResponse = response.result as? NewContactResponse
			updateContacts(chat: chat, contactsResponse: contactResponse)
            completion(contactResponse?.contacts ,response.uniqueId , response.error)
		}
	}
	
	private class func updateContacts(chat:Chat , contactsResponse:NewContactResponse?){
		if let contacts = contactsResponse?.contacts {
			CMContact.insertOrUpdate(contacts: contacts)
		}
		PSM.shared.save()
	}
	
}
