//
//  DownloadFileRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/2/21.
//

import Foundation
class DownloadFileRequestHandler{
    
    
    class func download(_ req              :FileRequest,
                        _ uniqueIdResult   :UniqueIdResultType       = nil,
                        _ downloadProgress :DownloadProgressType?    = nil,
                        _ completion       :DownloadFileCompletionType?  = nil,
                        _ cacheResponse    :DownloadFileCompletionType?  = nil){
       
        uniqueIdResult?(req.uniqueId)
        if req.forceToDownloadFromServer == true , let token = Chat.sharedInstance.createChatModel?.token{
            let url = "\(SERVICE_ADDRESSES_ENUM().PODSPACE_FILESERVER_ADDRESS)\(SERVICES_PATH.DRIVE_DOWNLOAD_FILE.rawValue)"
            let headers:[String :String] = ["_token_": token, "_token_issuer_": "1"]
            DownloadManager.download(url: url,uniqueId: req.uniqueId , headers: headers , parameters: try? req.asDictionary(), downloadProgress: downloadProgress) { data, response, error in
                if let response = response as? HTTPURLResponse , (200...300).contains(response.statusCode) , let headers = response.allHeaderFields as? [String : Any]{
                    if let data = data , let error = try? JSONDecoder().decode(ChatError.self, from: data) , error.hasError == true{
                        completion?(nil,nil,error)
                        return
                    }
                    var name:String? = nil
                    if let fileName = (headers["Content-Disposition"] as? String)?.replacingOccurrences(of: "\"", with: "").split(separator: "=").last{
                        name = String(fileName)
                    }
                    var type:String? = nil
                    if let mimetype = (headers["Content-Type"] as? String)?.split(separator: "/").last{
                        type = String(mimetype)
                    }
                    let size = Int((headers["Content-Length"] as? String) ?? "0")
                    let fileNameWithExtension = "\(name ?? "default").\(type ?? "none")"
                    let fileModel = FileModel(hashCode: req.hashCode, name: fileNameWithExtension, size: size, type: type)
                    if Chat.sharedInstance.createChatModel?.enableCache == true{
                        CacheFileManager.sharedInstance.saveFile(fileModel , data)
                    }
                    completion?(data,fileModel ,nil)
                }else {
                    let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String:Any]
                    let message = (headers?["errorMessage"] as? String) ?? ""
                    let code    = (headers?["errorCode"] as? Int) ?? 999
                    let error = ChatError(message: message, errorCode: code , hasError: true, content: nil)
                    completion?(nil,nil,error)
                }
            }
        }
        
        if let (fileModel,path) = CacheFileManager.sharedInstance.getFile(hashCode: req.hashCode) , cacheResponse != nil{
            let data = CacheFileManager.sharedInstance.getDataOfFileWith(filePath:path)
            cacheResponse?(data ,fileModel , nil)
        }
    }
    
}
