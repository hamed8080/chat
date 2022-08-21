//
//  MapReverseRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

class MapReverseRequestHandler {
	
	class func handle(_ req:MapReverseRequest,
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<MapReverse>,
                      _ uniqueIdResult: UniqueIdResultType = nil
    ){
		guard  let config = chat.config, let mapApiKey = config.mapApiKey else {
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "❌ map api key was null set it through config!")
            return
        }
		let url = "\(config.mapServer)\(Routes.MAP_REVERSE.rawValue)"
        let headers: [String : String] = ["Api-Key":  mapApiKey]
		chat.restApiRequest(req,
							decodeType: MapReverse.self,
							url: url,
							headers: headers,
                            uniqueIdResult:uniqueIdResult){ response in
            completion(response.result as? MapReverse , response.uniqueId , response.error)
        }
	}
	
}
