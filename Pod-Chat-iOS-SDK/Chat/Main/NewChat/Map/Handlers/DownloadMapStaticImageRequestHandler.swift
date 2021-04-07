//
//  DownloadMapStaticImageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation

class DownloadMapStaticImageRequestHandler {
    
    class func handle(req:NewMapStaticImageRequest ,
							   createChatModel:CreateChatModel ,
                               downloadProgress:DownloadProgressType? = nil,
                               completion:@escaping (ChatResponse)->()
							   )
	{
		
		guard let mapApiKey = createChatModel.mapApiKey else{return}
		req.key = mapApiKey
		let url = "\(createChatModel.mapServer)\(SERVICES_PATH.MAP_STATIC_IMAGE.rawValue)"
        DownloadManager.download(url: url , uniqueId: UUID().uuidString, headers: nil, parameters: try? req.asDictionary(), downloadProgress: downloadProgress) { data, response, error in
            if let data = data{
                let response = ChatResponse(result: data)
                completion(response)
            }
        }
	}
	
}
