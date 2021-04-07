//
//  MapReverseRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
import Alamofire

class MapReverseRequestHandler {
	
	class func handle( req:NewMapReverseRequest , chat:Chat ,uniqueIdResult: UniqueIdResultType = nil,completion: @escaping CompletionType<NewMapReverse>){
		guard  let createChatModel = chat.createChatModel, let mapApiKey = createChatModel.mapApiKey else {return}
		let url = "\(createChatModel.mapServer)\(SERVICES_PATH.MAP_REVERSE.rawValue)"
		let headers:  HTTPHeaders = ["Api-Key":  mapApiKey]
		chat.restApiRequest(req,
							decodeType: NewMapReverse.self,
							url: url,
							headers: headers,
							typeCode: req.typeCode,
                            uniqueIdResult:uniqueIdResult){ response in
            completion(response.result as? NewMapReverse , response.uniqueId , response.error)
        }
	}
	
}
