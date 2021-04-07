//
//  MapStaticImageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
import Alamofire

class MapStaticImageRequestHandler {
    
    class func handle(_ req:NewMapStaticImageRequest,
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<Data>,
                      _ uniqueIdResult:UniqueIdResultType = nil
                      ){
        guard  let config = chat.config else {return}
        DownloadMapStaticImageRequestHandler.handle(req:req , config: config , uniqueIdResult:uniqueIdResult){ response in
            completion(response.result as? Data , response.uniqueId , response.error)
        }
    }
    
}
