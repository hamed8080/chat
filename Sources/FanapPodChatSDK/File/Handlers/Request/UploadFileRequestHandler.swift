//
//  UploadFileRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/31/21.
//

import Foundation
class UploadFileRequestHandler{
    
    class func uploadFile(_ chat:Chat,
                          _ req:UploadFileRequest,
                          _ uploadCompletion: UploadCompletionType?,
                          _ uploadProgress:UploadFileProgressType? = nil,
                          _ uploadUniqueIdResult :UniqueIdResultType = nil){
        
        uploadUniqueIdResult?(req.uniqueId)
        let chatDelegate = Chat.sharedInstance.delegate
        
        guard let fileServer = chat.config?.fileServer else {return}
        let filePath:Routes = req.userGroupHash != nil ? .UPLOAD_FILE_WITH_USER_GROUP : .FILES
        let url = fileServer + filePath.rawValue.replacingOccurrences(of: "{userGroupHash}", with: req.userGroupHash ?? "")
        guard let token = chat.config?.token , let parameters = try? req.asDictionary() else{return}
        let headers = ["Authorization": "Bearer \(token)", "Content-type": "multipart/form-data"]
        
        CacheFactory.write(cacheType: .UPLOAD_FILE_QUEUE(req))
        PSM.shared.save()
        
        UploadManager.upload(url: url,
                             headers: headers,
                             parameters: parameters,
                             fileData: req.data,
                             fileName: req.fileName,
                             mimetype: req.mimeType,
                             uniqueId: req.uniqueId,
                             uploadProgress: uploadProgress) { data , response , error in
            //completed upload file
            if let data = data , let chatError = try? JSONDecoder().decode(ChatError.self, from: data) , chatError.hasError == true{
                uploadCompletion?(nil,nil,chatError)
                chatDelegate?.chatEvent(event: .File(.UPLOAD_ERROR(chatError)))
            } else if let data = data , let uploadResponse = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data){
                Chat.sharedInstance.logger?.log(title:"response is:\(String(data: data, encoding: .utf8) ?? "") ")
                if uploadResponse.error != nil {
                    let error = ChatError(message: "\(uploadResponse.error ?? "") - \(uploadResponse.message ??  "")", errorCode: uploadResponse.errorType?.rawValue , hasError: true)
                    uploadCompletion?(nil,nil,error)
                    chatDelegate?.chatEvent(event: .File(.UPLOAD_ERROR(error)))
                    return
                }
                if FanapPodChatSDK.Chat.sharedInstance.config?.isDebuggingLogEnabled == true {
                    Chat.sharedInstance.logger?.log(title: "file uploaded successfully", message: "\(String(data:data , encoding:.utf8) ?? "")")
                }
                let link = "\(fileServer)\(Routes.FILES.rawValue)/\(uploadResponse.result?.hash ?? "")"
                let fileDetail   = FileDetail(fileExtension: req.fileExtension,
                                              link: link,
                                              mimeType: req.mimeType,
                                              name: req.fileName,
                                              originalName: req.originalName,
                                              size: req.fileSize,
                                              fileHash: uploadResponse.result?.hash,
                                              hashCode: uploadResponse.result?.hash,
                                              parentHash: uploadResponse.result?.parentHash)
                let fileMetaData = FileMetaData(file: fileDetail, fileHash: uploadResponse.result?.hash, hashCode: uploadResponse.result?.hash, name: uploadResponse.result?.name)
                uploadCompletion?(uploadResponse.result,fileMetaData, nil)
                chatDelegate?.chatEvent(event: .File(.UPLOADED(req)))
                CacheFactory.write(cacheType: .DELETE_UPLOAD_FILE_QUEUE(req.uniqueId))
                PSM.shared.save()
            } else if let error = error {
                let error = ChatError(message: "\(ChatErrorCodes.NETWORK_ERROR.rawValue) \(error)", errorCode: 6200, hasError: true)
                uploadCompletion?(nil,nil,error)
                chatDelegate?.chatEvent(event: .File(.UPLOAD_ERROR(error)))
            }
        }
    }
    
}
