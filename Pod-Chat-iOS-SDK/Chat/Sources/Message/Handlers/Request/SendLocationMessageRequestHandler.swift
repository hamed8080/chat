//
//  SendLocationMessageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/31/21.
//

import Foundation
class SendLocationMessageRequestHandler {
    
    class func handle(_ chat:Chat,
                      _ request:LocationMessageRequest,
                      _ downloadProgress:DownloadProgressType? = nil,
                      _ uploadProgress:UploadFileProgressType? = nil,
                      _ onSent:OnSentType = nil,
                      _ onSeen:OnSeenType = nil,
                      _ onDeliver:OnDeliveryType = nil,
                      _ uploadUniqueIdResult: UniqueIdResultType = nil,
                      _ messageUniqueIdResult: UniqueIdResultType = nil){
        
        guard let config = chat.config else {return}
        let mapStaticReq = MapStaticImageRequest(center: request.mapCenter,
                                                    key: nil,
                                                    height: request.mapHeight,
                                                    width: request.mapWidth,
                                                    zoom: request.mapZoom,
                                                    type: request.mapType)
        
        DownloadMapStaticImageRequestHandler.handle(req: mapStaticReq, config:config , downloadProgress: downloadProgress){ response in
        
            guard let data = response.result as? Data , let image = UIImage(data: data) else{return}
            let imageRequest = UploadImageRequest(data: data,
                                                    hC: Int(image.size.height),
                                                    wC: Int(image.size.width),
                                                    fileExtension: ".png",
                                                    fileName:  request.mapImageName,
                                                    mimeType: "image/png",
                                                    userGroupHash: request.userGroupHash,
                                                    uniqueId: request.uniqueId)
            
            let textMessage = SendTextMessageRequest(threadId: request.threadId,
                                      textMessage: request.textMessage ?? "",
                                      messageType: .POD_SPACE_PICTURE,
                                      repliedTo: request.repliedTo,
                                      systemMetadata: request.systemMetadata,
                                      uniqueId: request.uniqueId)
            
            chat.sendFileMessage(textMessage: textMessage,
                                 uploadFile: imageRequest,
                                 uploadProgress: uploadProgress,
                                 onSent: onSent,
                                 onSeen: onSeen,
                                 onDeliver: onDeliver,
                                 uploadUniqueIdResult: uploadUniqueIdResult,
                                 messageUniqueIdResult: messageUniqueIdResult)
        }
    }
}
