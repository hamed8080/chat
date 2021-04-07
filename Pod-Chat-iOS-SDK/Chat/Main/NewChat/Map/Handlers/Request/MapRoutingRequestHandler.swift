//
//  MapRoutingRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
import Alamofire

class MapRoutingRequestHandler {
	
    class func handle( req:NewMapRoutingRequest , chat:Chat ,uniqueIdResult: UniqueIdResultType = nil,completion: @escaping CompletionType<[Route]>){
        guard  let createChatModel = chat.createChatModel, let mapApiKey = createChatModel.mapApiKey else {return}
        let url = "\(createChatModel.mapServer)\(SERVICES_PATH.MAP_ROUTING.rawValue)"
        let headers:  HTTPHeaders = ["Api-Key":  mapApiKey]
        chat.restApiRequest(req,
                            decodeType: NewMapRoutingResponse.self,
                            url: url,
                            headers: headers,
                            typeCode: req.typeCode,
                            uniqueIdResult:uniqueIdResult)
        { response in
            let routeResponse = response.result as? NewMapRoutingResponse
            completion(routeResponse?.routes , response.uniqueId , response.error)
        }
    }
	
}
