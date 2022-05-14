//
//  AddContactsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation
import Alamofire

class AddContactsRequestHandler{
    
    class func handle(_ req:[AddContactRequest],
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<[Contact]>,
                      _ uniqueIdsResult:UniqueIdsResultType = nil
                      ){
        guard let config = chat.config else {return}
        uniqueIdsResult?(req.map{$0.uniqueId})
        let url = "\(config.platformHost)\(Routes.ADD_CONTACTS.rawValue)"
        let headers: [String:String]    = ["_token_": config.token, "_token_issuer_": "1"]
        var urlComp = URLComponents(string: url)!
        urlComp.queryItems = []
        req.forEach { contact in
            
            //****
                //do not use if let to only pass un nil value if you pass un nil value in some property like email value are null so
                //the number of paramter is not equal in all contact and get invalid request like below:
                //[firstname,lastname,email,cellPhoneNumber],[firstname,lastname,cellPhoneNumber]
            //****
            urlComp.queryItems?.append(URLQueryItem(name: "firstName", value: contact.firstName))
            urlComp.queryItems?.append(URLQueryItem(name: "lastName", value: contact.lastName))
            urlComp.queryItems?.append(URLQueryItem(name: "email", value: contact.email))
            urlComp.queryItems?.append(URLQueryItem(name: "cellphoneNumber", value: contact.cellphoneNumber))
            if let userName = contact.username {
                urlComp.queryItems?.append(URLQueryItem(name: "username", value: userName))
            }
            urlComp.queryItems?.append(URLQueryItem(name: "uniqueId", value: contact.uniqueId))
        }
        guard let urlString  = urlComp.string else {return}
        RequestManager.request(ofType: ContactResponse.self, bodyData: nil, url: urlString, method: .post, headers: headers) { response, error in
            addToCacheIfEnabled(chat: chat, contacts:response?.contacts)
            completion(response?.contacts,req.first?.uniqueId , error)
        }
    }
    
    class func addToCacheIfEnabled(chat:Chat , contacts:[Contact]?){
        if chat.config?.enableCache == true , let contacts = contacts{
            CMContact.insertOrUpdate(contacts: contacts)
        }
    }
}
