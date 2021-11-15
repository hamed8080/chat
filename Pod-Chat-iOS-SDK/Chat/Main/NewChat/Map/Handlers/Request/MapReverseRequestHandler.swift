//
//  MapReverseRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
import Alamofire

class MapReverseRequestHandler {
	
	class func handle(_ req:NewMapReverseRequest,
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<NewMapReverse>,
                      _ uniqueIdResult: UniqueIdResultType = nil
    ){
		guard  let config = chat.config, let mapApiKey = config.mapApiKey else {
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "❌ map api key was null set it through config!")
            return
        }
		let url = "\(config.mapServer)\(SERVICES_PATH.MAP_REVERSE.rawValue)"
		let headers:  HTTPHeaders = ["Api-Key":  mapApiKey]
		chat.restApiRequest(req,
							decodeType: NewMapReverse.self,
							url: url,
							headers: headers,
                            uniqueIdResult:uniqueIdResult){ response in
            completion(response.result as? NewMapReverse , response.uniqueId , response.error)
        }
	}
	
}
