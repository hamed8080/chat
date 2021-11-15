//
//  MapSearchRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
import Alamofire

class MapSearchRequestHandler {
	
	class func handle( _ req:NewMapSearchRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<[NewMapItem]>,
                       _ uniqueIdResult: UniqueIdResultType = nil){
		guard  let config = chat.config, let mapApiKey = config.mapApiKey else {
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "❌ map api key was null set it through config!")
            return            
        }
		let url = "\(config.mapServer)\(SERVICES_PATH.MAP_SEARCH.rawValue)"
		let headers:  HTTPHeaders = ["Api-Key":  mapApiKey]
		chat.restApiRequest(req,
							decodeType: NewMapSearchResponse.self,
							url: url,
							headers: headers,
							uniqueIdResult:uniqueIdResult,
							completion: { response in
                                let mapSearchResponse = response.result as? NewMapSearchResponse
                                completion( mapSearchResponse?.items,response.uniqueId , response.error)
                            }
		)
	}
	
}
