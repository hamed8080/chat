//
//  DownloadMapStaticImageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation

class DownloadMapStaticImageRequestHandler {
    
    class func handle(req:NewMapStaticImageRequest ,
							   config:ChatConfig ,
                               downloadProgress:DownloadProgressType? = nil,
                               uniqueIdResult:UniqueIdResultType = nil,
                               completion:@escaping (ChatResponse)->()
							   )
	{
        uniqueIdResult?(req.uniqueId)
		guard let mapApiKey = config.mapApiKey else{
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "❌ map api key was null set it through config!")
            return
        }
		req.key = mapApiKey
		let url = "\(config.mapServer)\(SERVICES_PATH.MAP_STATIC_IMAGE.rawValue)"
        DownloadManager.download(url: url , uniqueId: req.uniqueId, headers: nil, parameters: try? req.asDictionary(), downloadProgress: downloadProgress) { data, response, error in
            if let data = data{
                let response = ChatResponse(result: data)
                completion(response)
            }
        }
	}
	
}
