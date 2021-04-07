//
//  MapStaticImageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
import Alamofire

class MapStaticImageRequestHandler {
    
    class func handle( req:NewMapStaticImageRequest , chat:Chat ,uniqueIdResult:((String)->())? = nil,completion: @escaping CompletionType<Data>){
        guard  let createChatModel = chat.createChatModel else {return}
        DownloadMapStaticImageRequestHandler.handle(req:req , createChatModel: createChatModel){ response in
            completion(response.result as? Data , response.uniqueId , response.error)
        }
    }
    
}
