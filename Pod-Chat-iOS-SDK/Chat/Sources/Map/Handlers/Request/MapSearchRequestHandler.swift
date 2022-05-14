//
//  MapSearchRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
import Alamofire

class MapSearchRequestHandler {
	
	class func handle( _ req:MapSearchRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<[MapItem]>,
                       _ uniqueIdResult: UniqueIdResultType = nil){
		guard  let config = chat.config, let mapApiKey = config.mapApiKey else {
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "❌ map api key was null set it through config!")
            return            
        }
		let url = "\(config.mapServer)\(Routes.MAP_SEARCH.rawValue)"
		let headers:  HTTPHeaders = ["Api-Key":  mapApiKey]
		chat.restApiRequest(req,
							decodeType: MapSearchResponse.self,
							url: url,
							headers: headers,
							uniqueIdResult:uniqueIdResult,
							completion: { response in
                                let mapSearchResponse = response.result as? MapSearchResponse
                                completion( mapSearchResponse?.items,response.uniqueId , response.error)
                            }
		)
	}
	
}
