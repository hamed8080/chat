//
//  DownloadImageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/2/21.
//

import Foundation
class DownloadImageRequestHandler{
    
    
    class func download(_ req              :ImageRequest,
                        _ uniqueIdResult   :UniqueIdResultType       = nil,
                        _ downloadProgress :DownloadProgressType?    = nil,
                        _ completion       :DownloadImageCompletionType?  = nil,
                        _ cacheResponse    :DownloadImageCompletionType?  = nil){
        
        uniqueIdResult?(req.uniqueId)
        let chatDelegate = Chat.sharedInstance.delegate
        
        /// check if file exist on cache or not if it doesn't exist force to download it become true
        if CacheFileManager.sharedInstance.getImage(hashCode: req.hashCode)  == nil{
            req.forceToDownloadFromServer = true
        }
        
        if req.forceToDownloadFromServer == true , let token = Chat.sharedInstance.config?.token , let fileServer = Chat.sharedInstance.config?.fileServer{
            let url = "\(fileServer)\(Routes.IMAGES.rawValue)/\(req.hashCode)"
            let headers:[String :String] = ["Authorization": "Bearer \(token)"]
            DownloadManager.download(url: url,uniqueId: req.uniqueId, headers: headers, parameters: try? req.asDictionary(), downloadProgress: downloadProgress) { data, response, error in
                if let response = response as? HTTPURLResponse , (200...300).contains(response.statusCode) , let headers = response.allHeaderFields as? [String : Any]{
                    if let data = data , let error = try? JSONDecoder().decode(ChatError.self, from: data) , error.hasError == true{
                        completion?(nil,nil,error)
                        chatDelegate?.chatEvent(event: .File(.init(type:.DOWNLOAD_ERROR, error: error)))
                        return
                    }
                    if let data = data ,let podspaceError = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data){
                        let error = ChatError(message: podspaceError.message, errorCode: podspaceError.errorType?.rawValue, hasError: true)
                        completion?(nil,nil, error)
                        chatDelegate?.chatEvent(event: .File(.init(type:.DOWNLOAD_ERROR, error: error)))
                        return
                    }
                    
                    var name:String? = nil
                    if let fileName = (headers["Content-Disposition"] as? String)?.replacingOccurrences(of: "\"", with: "").split(separator: "=").last{
                        name = String(fileName)
                    }
                    
                    let size = Int((headers["Content-Length"] as? String) ?? "0")
                    let fileNameWithExtension = "\(name ?? "default")"
                    var imageModel = ImageModel(hashCode: req.hashCode, name: fileNameWithExtension, size: size)
                    if Chat.sharedInstance.config?.enableCache == true{
                        imageModel.hashCode = req.isThumbnail ? (req.hashCode + "-Thumbnail") : req.hashCode
                        CacheFileManager.sharedInstance.saveImage(imageModel, req.isThumbnail , data)
                    }
                    completion?(data,imageModel ,nil)
                    chatDelegate?.chatEvent(event: .File(.init(type:.DOWNLOADED, downloadImageRequest: req)))
                }else {
                    let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String:Any]
                    let message = (headers?["errorMessage"] as? String) ?? ""
                    let code    = (headers?["errorCode"] as? Int) ?? 999
                    let error = ChatError(message: message, errorCode: code , hasError: true, content: nil)
                    completion?(nil,nil,error)
                    chatDelegate?.chatEvent(event: .File(.init(type:.DOWNLOAD_ERROR, error: error)))
                }
            }
        }
        
        if cacheResponse != nil{
            if req.isThumbnail , let (fileModel,path) = CacheFileManager.sharedInstance.getThumbnail(hashCode: req.hashCode){
                let data = CacheFileManager.sharedInstance.getDataOfFileWith(filePath:path)
                cacheResponse?(data ,fileModel , nil)
            }else if let (fileModel,path) = CacheFileManager.sharedInstance.getImage(hashCode: req.hashCode){
                let data = CacheFileManager.sharedInstance.getDataOfFileWith(filePath:path)
                cacheResponse?(data ,fileModel , nil)
            }
        }
    }
    
}
