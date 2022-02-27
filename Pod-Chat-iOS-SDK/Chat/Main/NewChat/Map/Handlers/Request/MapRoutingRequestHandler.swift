//
//  MapRoutingRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
import Alamofire

class MapRoutingRequestHandler {
	
    class func handle(_ req:NewMapRoutingRequest,
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<[Route]>,
                      _ uniqueIdResult: UniqueIdResultType = nil
    ){
        guard  let config = chat.config, let mapApiKey = config.mapApiKey else {
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "❌ map api key was null set it through config!")
            return            
        }
        let url = "\(config.mapServer)\(SERVICES_PATH.MAP_ROUTING.rawValue)"
        let headers:  HTTPHeaders = ["Api-Key":  mapApiKey]
        chat.restApiRequest(req,
                            decodeType: NewMapRoutingResponse.self,
                            url: url,
                            headers: headers,
                            uniqueIdResult:uniqueIdResult)
        { response in
            let routeResponse = response.result as? NewMapRoutingResponse
            completion(routeResponse?.routes , response.uniqueId , response.error)
        }
    }
	
}
