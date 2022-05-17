//
//  UploadImageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/31/21.
//

import Foundation
class UploadImageRequestHandler{
    
    class func uploadImage(_ chat:Chat,
                           _ req:UploadImageRequest,
                           _ uploadCompletion: UploadCompletionType? = nil,
                           _ uploadProgress:UploadFileProgressType? = nil,
                           _ uploadUniqueIdResult :UniqueIdResultType = nil){
        
        uploadUniqueIdResult?(req.uniqueId)
        let chatDelegate = Chat.sharedInstance.delegate

        guard let fileServer = chat.config?.fileServer else {return}
        let imagePath:Routes = req.userGroupHash != nil ? .UPLOAD_IMAGE_WITH_USER_GROUP : .IMAGES
        let url = fileServer + imagePath.rawValue.replacingOccurrences(of: "{userGroupHash}", with: req.userGroupHash ?? "")
        guard let token = chat.config?.token , let parameters = try? req.asDictionary() else{return}
        let headers = ["Authorization": "Bearer \(token)", "Content-type": "multipart/form-data"]
        
        CacheFactory.write(cacheType: .UPLOAD_IMAGE_QUEUE(req))
        PSM.shared.save()
        
        UploadManager.upload(url: url,
                             headers: headers,
                             parameters: parameters,
                             fileData: req.data,
                             fileName: req.fileName,
                             mimetype: req.mimeType,
                             uniqueId: req.uniqueId,
                             uploadProgress: uploadProgress) { data , response , error in
            if let data = data , let chatError = try? JSONDecoder().decode(ChatError.self, from: data) , chatError.hasError == true{
                uploadCompletion?(nil,nil,chatError)
            }else if let data = data , let uploadResponse = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data){
                if uploadResponse.error != nil {
                    let error = ChatError(message: "\(uploadResponse.error ?? "") - \(uploadResponse.message ??  "")", errorCode: uploadResponse.errorType?.rawValue , hasError: true)
                    uploadCompletion?(nil,nil,error)
                    chatDelegate?.chatEvent(event: .File(.init(type:.UPLOAD_ERROR, error: error)))
                    return
                }
                if FanapPodChatSDK.Chat.sharedInstance.config?.isDebuggingLogEnabled == true {
                    Chat.sharedInstance.logger?.log(title: "file uploaded successfully",message: "\(String(data:data , encoding:.utf8) ?? "")")
                }
                let link = "\(fileServer)\(Routes.IMAGES.rawValue)/\(uploadResponse.result?.hash ?? "")"
                let fileDetail   = FileDetail(fileExtension: req.fileExtension,
                                              link: link,
                                              mimeType: req.mimeType,
                                              name: req.fileName,
                                              originalName: req.originalName,
                                              size: req.fileSize,
                                              fileHash: uploadResponse.result?.hash,
                                              hashCode: uploadResponse.result?.hash,
                                              parentHash: uploadResponse.result?.parentHash,
                                              actualHeight: req.hC,
                                              actualWidth: req.wC
                )
                let fileMetaData = FileMetaData(file: fileDetail, fileHash: uploadResponse.result?.hash, hashCode: uploadResponse.result?.hash, name: uploadResponse.result?.name)
                uploadCompletion?(uploadResponse.result ,fileMetaData , nil)
                CacheFactory.write(cacheType: .DELETE_UPLOAD_IMAGE_QUEUE(req.uniqueId))
                PSM.shared.save()
                chatDelegate?.chatEvent(event: .File(.init(type:.UPLOADED, uploadFileRequest: req)))
            }else if let error = error {
                let error = ChatError(message: "\(ChatErrorCodes.NETWORK_ERROR.rawValue) \(error)", errorCode: 6200, hasError: true)
                uploadCompletion?(nil,nil,error)
                chatDelegate?.chatEvent(event: .File(.init(type:.UPLOAD_ERROR, error: error)))
            }
        }
    }
    
}
