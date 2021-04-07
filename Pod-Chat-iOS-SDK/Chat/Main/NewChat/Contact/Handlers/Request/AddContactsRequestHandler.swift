//
//  AddContactsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation
import Alamofire

class AddContactsRequestHandler{
    
    class func handle( req:[NewAddContactRequest] , chat:Chat , typeCode:String? = nil , completion: @escaping CompletionType<[Contact]>){
        
        guard let createChatModel = chat.createChatModel , let data = try? JSONEncoder().encode(req) else {return}
        let url = "\(createChatModel.platformHost)\(SERVICES_PATH.ADD_CONTACTS.rawValue)"
        let headers: HTTPHeaders    = ["_token_": createChatModel.token, "_token_issuer_": "1"]
        RequestManager.request(ofType: NewContactResponse.self, bodyData: data, url: url, method: .post, headers: headers) { response,error  in
            addToCacheIfEnabled(chat: chat, contacts:response?.contacts)
            completion(response?.contacts,req.first?.uniqueId , error)
        }
    }
    
    class func addToCacheIfEnabled(chat:Chat , contacts:[Contact]?){
        if chat.createChatModel?.enableCache == true , let contacts = contacts{
            CMContact.insertOrUpdate(contacts: contacts)
        }
    }
}
