//
//  FileManagementMethods.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON
import Alamofire

// MARK: - Public Methods -
// MARK: - File Management

extension Chat {
    
    // MARK: - Upload Image/File
    
    /// UploadImage:
    /// upload some image.
    ///
    /// By calling this function, HTTP request of type (UPLOAD_IMAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UploadImageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UploadImageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter progress:   (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (UploadImageModel)
    func uploadImage(inputModel uploadImageInput:   UploadImageRequestModel,
                     uniqueId:      @escaping (String) -> (),
                     progress:      @escaping (Float) -> (),
                     completion:    @escaping callbackTypeAlias) {
        
        log.verbose("Try to upload image with this parameters: \n \(uploadImageInput)", context: "Chat")
        
        uniqueId(uploadImageInput.uniqueId)
        
        if (enableCache) && (uploadImageInput.threadId != nil) {
            /**
             seve this upload image on the Cache Wait Queue,
             so if there was an situation that response of the server to this uploading doesn't come, then we know that our upload request didn't sent correctly
             and we will send this Queue to user on the GetHistory request,
             now user knows which upload requests didn't send correctly, and can handle them
             */
            let messageObjectToSendToQueue = QueueOfWaitUploadImagesModel(dataToSend:         uploadImageInput.dataToSend,
                                                                          fileExtension:      uploadImageInput.fileExtension,
                                                                          fileName:           uploadImageInput.fileName,
                                                                          fileSize:           uploadImageInput.fileSize,
                                                                          originalFileName:   uploadImageInput.originalFileName,
                                                                          threadId:           uploadImageInput.threadId,
                                                                          xC:                 uploadImageInput.xC,
                                                                          yC:                 uploadImageInput.yC,
                                                                          hC:                 uploadImageInput.hC,
                                                                          wC:                 uploadImageInput.wC,
                                                                          typeCode:           uploadImageInput.typeCode,
                                                                          uniqueId:           uploadImageInput.uniqueId)
            Chat.cacheDB.saveUploadImageToWaitQueue(image: messageObjectToSendToQueue)
        }
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.UPLOAD_IMAGE.rawValue)"
        let headers:    HTTPHeaders = ["_token_":           token,
                                       "_token_issuer_":    "1",
                                       "Content-type":      "multipart/form-data"]
        
        var uploadProgress: Float = 0
        Networking.sharedInstance.upload(toUrl:             url,
                                         withHeaders:       headers,
                                         withParameters:    uploadImageInput.convertContentToParameters(),
                                         isImage:           true,
                                         isFile:            false,
                                         dataToSend:        uploadImageInput.dataToSend,
                                         uniqueId:          uploadImageInput.uniqueId,
                                         progress:
            { (myProgress) in
                uploadProgress = myProgress
                let fileInfo = FileInfo(fileName: uploadImageInput.fileName,
                                        fileSize: uploadImageInput.fileSize)
                let fUploadedEM = FileUploadEventModel(type:            FileUploadEventTypes.UPLOADING,
                                                       errorCode:       nil,
                                                       errorMessage:    nil,
                                                       errorEvent:      nil,
                                                       fileInfo:        fileInfo,
                                                       fileObjectData:  nil,
                                                       progress:        uploadProgress,
                                                       threadId:        uploadImageInput.threadId,
                                                       uniqueId:        uploadImageInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadedEM)
                progress(myProgress)
        }) { (response) in
            let myResponse: JSON = response as! JSON
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["errorMessage"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                
                if self.enableCache {
                    // save data comes from server to the Cache
                    let uploadImageFile = ImageObject(messageContent: resultData)
                    Chat.cacheDB.saveImageObject(imageInfo: uploadImageFile, imageData: uploadImageInput.dataToSend)
                    let getImageRequest = GetImageRequestModel(actual:      nil,
                                                               downloadable: nil,
                                                               height:      nil,
                                                               hashCode:    uploadImageFile.hashCode,
                                                               imageId:     uploadImageFile.id,
                                                               width:       nil,
                                                               serverResponse: true)
                    self.sendRequestToDownloadImage(withInputModel: getImageRequest,
                                                    progress:       { _ in },
                                                    completion:     { (_, _) in })
                    Chat.cacheDB.deleteWaitUploadImages(uniqueId: uploadImageInput.uniqueId)
                }
                
                let uploadImageModel = UploadImageModel(messageContentJSON: resultData,
                                                        errorCode:          errorCode,
                                                        errorMessage:       errorMessage,
                                                        hasError:           hasError)
                
                let fileInfo = FileInfo(fileName: uploadImageInput.fileName,
                                        fileSize: uploadImageInput.fileSize)
                let fUploadedEM = FileUploadEventModel(type:            FileUploadEventTypes.UPLOADED,
                                                       errorCode:       errorCode,
                                                       errorMessage:    errorMessage,
                                                       errorEvent:      nil,
                                                       fileInfo:        fileInfo,
                                                       fileObjectData:  nil,
                                                       progress:        uploadProgress,
                                                       threadId:        uploadImageInput.threadId,
                                                       uniqueId:        uploadImageInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadedEM)
                
                completion(uploadImageModel)
            } else {
                let fileInfo = FileInfo(fileName: uploadImageInput.fileName,
                                        fileSize: uploadImageInput.fileSize)
                let fUploadErrorEM = FileUploadEventModel(type:             FileUploadEventTypes.UPLOAD_ERROR,
                                                          errorCode:        errorCode,
                                                          errorMessage:     errorMessage,
                                                          errorEvent:       nil,
                                                          fileInfo:         fileInfo,
                                                          fileObjectData:   uploadImageInput.dataToSend,
                                                          progress:         uploadProgress,
                                                          threadId:         uploadImageInput.threadId,
                                                          uniqueId:         uploadImageInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadErrorEM)
            }
        }
        
    }
    
    
    /// UploadFile:
    /// upload some file.
    ///
    /// By calling this function, HTTP request of type (UPLOAD_FILE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UploadFileRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UploadFileRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter progress:   (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (UploadFileModel)
     func uploadFile(inputModel uploadFileInput: UploadFileRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           progress:        @escaping (Float) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        log.verbose("Try to upload file with this parameters: \n \(uploadFileInput)", context: "Chat")
        
        uniqueId(uploadFileInput.uniqueId)
        
        if (enableCache) && (uploadFileInput.threadId != nil) {
            /*
             seve this upload image on the Cache Wait Queue,
             so if there was an situation that response of the server to this uploading doesn't come, then we know that our upload request didn't sent correctly
             and we will send this Queue to user on the GetHistory request,
             now user knows which upload requests didn't send correctly, and can handle them
             */
            let messageObjectToSendToQueue = QueueOfWaitUploadFilesModel(dataToSend:        uploadFileInput.dataToSend,
                                                                         fileExtension:     uploadFileInput.fileExtension,
                                                                         fileName:          uploadFileInput.fileName,
                                                                         fileSize:          uploadFileInput.fileSize,
                                                                         originalFileName:  uploadFileInput.originalFileName,
                                                                         threadId:          uploadFileInput.threadId,
                                                                         typeCode:          uploadFileInput.typeCode,
                                                                         uniqueId:          uploadFileInput.uniqueId)
            Chat.cacheDB.saveUploadFileToWaitQueue(file: messageObjectToSendToQueue)
        }
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.UPLOAD_FILE.rawValue)"
        let headers:    HTTPHeaders = ["_token_":           token,
                                       "_token_issuer_":    "1",
                                       "Content-type":      "multipart/form-data"]
        
        var uploadProgress: Float = 0
        Networking.sharedInstance.upload(toUrl:             url,
                                         withHeaders:       headers,
                                         withParameters:    uploadFileInput.convertContentToParameters(),
                                         isImage:           false,
                                         isFile:            true,
                                         dataToSend:        uploadFileInput.dataToSend,
                                         uniqueId:          uploadFileInput.uniqueId,
                                         progress:
            { (myProgress) in
                uploadProgress = myProgress
                let fileInfo = FileInfo(fileName: uploadFileInput.fileName,
                                        fileSize: uploadFileInput.fileSize)
                let fUploadedEM = FileUploadEventModel(type:            FileUploadEventTypes.UPLOADING,
                                                       errorCode:       nil,
                                                       errorMessage:    nil,
                                                       errorEvent:      nil,
                                                       fileInfo:        fileInfo,
                                                       fileObjectData:  nil,
                                                       progress:        uploadProgress,
                                                       threadId:        uploadFileInput.threadId,
                                                       uniqueId:        uploadFileInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadedEM)
                progress(myProgress)
        }) { (response) in
            let myResponse: JSON = response as! JSON
            
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["errorMessage"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                
                if self.enableCache {
                    // save data comes from server to the Cache
                    let uploadFileObject = FileObject(messageContent: resultData)
                    Chat.cacheDB.saveFileObject(fileInfo: uploadFileObject, fileData: uploadFileInput.dataToSend)
                    let getFileRequest = GetFileRequestModel(downloadable:  nil,
                                                             fileId:        uploadFileObject.id,
                                                             hashCode:      uploadFileObject.hashCode,
                                                             serverResponse: true)
                    self.sendRequestToDownloadFile(withInputModel:  getFileRequest,
                                                   progress:        { _ in },
                                                   completion:      { (_, _) in })
                    Chat.cacheDB.deleteWaitUploadFiles(uniqueId: uploadFileInput.uniqueId)
                }
                
                let fileInfo = FileInfo(fileName: uploadFileInput.fileName,
                                        fileSize: uploadFileInput.fileSize)
                let fUploadedEM = FileUploadEventModel(type:            FileUploadEventTypes.UPLOADED,
                                                       errorCode:       errorCode,
                                                       errorMessage:    errorMessage,
                                                       errorEvent:      nil,
                                                       fileInfo:        fileInfo,
                                                       fileObjectData:  nil,
                                                       progress:        uploadProgress,
                                                       threadId:        uploadFileInput.threadId,
                                                       uniqueId:        uploadFileInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadedEM)
                
                let uploadFileModel = UploadFileModel(messageContentJSON:   resultData,
                                                      errorCode:            errorCode,
                                                      errorMessage:         errorMessage,
                                                      hasError:             hasError)
                
                completion(uploadFileModel)
            } else {
                let fileInfo = FileInfo(fileName: uploadFileInput.fileName,
                                        fileSize: uploadFileInput.fileSize)
                let fUploadErrorEM = FileUploadEventModel(type:             FileUploadEventTypes.UPLOAD_ERROR,
                                                          errorCode:        errorCode,
                                                          errorMessage:     errorMessage,
                                                          errorEvent:       nil,
                                                          fileInfo:         fileInfo,
                                                          fileObjectData:   uploadFileInput.dataToSend,
                                                          progress:         uploadProgress,
                                                          threadId:         uploadFileInput.threadId,
                                                          uniqueId:         uploadFileInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadErrorEM)
            }
        }
        
    }
    
    
    // MARK: - Get Image/File
    
    /// GetImage:
    /// get specific image.
    ///
    /// By calling this function, HTTP request of type (GET_IMAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetImageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (GetImageRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter progress:       (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Data?, UploadImageModel)
    /// - parameter cacheResponse:  (response) it will returns the response from CacheDB if user has enabled it. (UploadImageModel, String)
    public func getImage(inputModel getImageInput: GetImageRequestModel,
                         uniqueId:      @escaping (String) -> (),
                         progress:      @escaping (Float) -> (),
                         completion:    @escaping (Data?, DownloadImageModel) -> (),
                         cacheResponse: @escaping (Data, DownloadImageModel) -> ()) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        var hasImageOnTheCache = false
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            if let (cacheImageResult, imagePath) = Chat.cacheDB.retrieveImageObject(hashCode:   getImageInput.hashCode,
                                                                                    imageId:    getImageInput.imageId) {
                let response = DownloadImageModel(messageContentModel:   cacheImageResult,
                                                  errorCode:             0,
                                                  errorMessage:          "",
                                                  hasError:              false)
                if FileManager.default.fileExists(atPath: imagePath) {
                    let imagURL = URL(fileURLWithPath: imagePath)
                    do {
                        let data = try Data(contentsOf: imagURL)
                        hasImageOnTheCache = true
                        cacheResponse(data, response)
                    } catch {
                        fatalError("cannot get the fileData from imagPath")
                    }
                }
            }
        }
        
        if (!hasImageOnTheCache) || (getImageInput.serverResponse) {
            sendRequestToDownloadImage(withInputModel: getImageInput, progress: { (theProgress) in
                progress(theProgress)
            }) { (data, imageModel) in
                completion(data, imageModel)
            }
        }
        
    }
    
    private func sendRequestToDownloadImage(withInputModel getImageInput: GetImageRequestModel,
                                            progress:      @escaping (Float) -> (),
                                            completion:    @escaping (Data?, DownloadImageModel) -> ()) {
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        Networking.sharedInstance.download(toUrl:           url,
                                           withMethod:      method,
                                           withHeaders:     nil,
                                           withParameters:  getImageInput.convertContentToParameters(),
                                           progress: { (myProgress) in
                                            progress(myProgress)
        }) { (imageDataResponse, responseHeader)  in
            if let myData = imageDataResponse {
                // save data comes from server to the Cache
                let fileName = responseHeader["name"].string
                let fileType = responseHeader["type"].string
                let theFinalFileName = "\(fileName ?? "default").\(fileType ?? "none")"
                let uploadImage = ImageObject(actualHeight: nil,
                                              actualWidth:  nil,
                                              hashCode:     getImageInput.hashCode,
                                              height:       getImageInput.height,
                                              id:           getImageInput.imageId,
                                              name:         theFinalFileName,
                                              width:        getImageInput.width)
                
                if self.enableCache {
                    Chat.cacheDB.saveImageObject(imageInfo: uploadImage, imageData: myData)
                }
                
                let uploadImageModel = DownloadImageModel(messageContentModel: uploadImage, errorCode: 0, errorMessage: "", hasError: false)
                completion(myData, uploadImageModel)
            } else {
                let hasError = responseHeader["hasError"].bool ?? false
                let errorMessage = responseHeader["errorMessage"].string ?? ""
                let errorCode = responseHeader["errorCode"].int ?? 999
                let errorUploadImageModel = DownloadImageModel(messageContentModel: nil, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                completion(nil, errorUploadImageModel)
            }
        }
    }
    
    
    
    /// GetFIle:
    /// get specific file.
    ///
    /// By calling this function, HTTP request of type (GET_FILE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetFileRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (GetFileRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter progress:       (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Data?, UploadFileModel)
    /// - parameter cacheResponse:  (response) it will returns the response from CacheDB if user has enabled it. (UploadFileModel, String)
    public func getFile(inputModel getFileInput:   GetFileRequestModel,
                        uniqueId:       @escaping (String) -> (),
                        progress:       @escaping (Float) -> (),
                        completion:     @escaping (Data?, DownloadFileModel) -> (),
                        cacheResponse:  @escaping (Data, DownloadFileModel) -> ()) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        var hasFileOntheCache = false
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            if let (cacheFileResult, filePath) = Chat.cacheDB.retrieveFileObject(fileId:   getFileInput.fileId,
                                                                                  hashCode: getFileInput.hashCode) {
                hasFileOntheCache = true
                let response = DownloadFileModel(messageContentModel:   cacheFileResult,
                                                 errorCode:             0,
                                                 errorMessage:          "",
                                                 hasError:              false)
                if FileManager.default.fileExists(atPath: filePath) {
                    let fileURL = URL(fileURLWithPath: filePath)
                    do {
                        let data = try Data(contentsOf: fileURL)
                        hasFileOntheCache = true
                        cacheResponse(data, response)
                    } catch {
                        fatalError("cannot get the fileData from imagPath")
                    }
                }
            }
        }
        
        if (!hasFileOntheCache) || (getFileInput.serverResponse) {
            sendRequestToDownloadFile(withInputModel: getFileInput, progress: { (theProgress) in
                progress(theProgress)
            }) { (data, fileModel) in
                completion(data, fileModel)
            }
        }
        
    }
    
    private func sendRequestToDownloadFile(withInputModel getFileInput:   GetFileRequestModel,
                                           progress:       @escaping (Float) -> (),
                                           completion:     @escaping (Data?, DownloadFileModel) -> ()) {
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        Networking.sharedInstance.download(toUrl:           url,
                                           withMethod:      method,
                                           withHeaders:     nil,
                                           withParameters:  getFileInput.convertContentToParameters(),
                                           progress: { (myProgress) in
                                            progress(myProgress)
        }) { (fileDataResponse, responseHeader) in
            if let myFile = fileDataResponse {
                // save data comes from server to the Cache
                let fileName = responseHeader["name"].string
                let fileType = responseHeader["type"].string
                let theFinalFileName = "\(fileName ?? "default").\(fileType ?? "none")"
                let uploadFile = FileObject(hashCode: getFileInput.hashCode, id: getFileInput.fileId, name: theFinalFileName)
                Chat.cacheDB.saveFileObject(fileInfo: uploadFile, fileData: myFile)
                
                let uploadFileModel = DownloadFileModel(messageContentModel:    uploadFile,
                                                        errorCode:              0,
                                                        errorMessage:           "",
                                                        hasError:               false)
                
                completion(myFile, uploadFileModel)
            } else {
                let hasError = responseHeader["hasError"].bool ?? false
                let errorMessage = responseHeader["errorMessage"].string ?? ""
                let errorCode = responseHeader["errorCode"].int ?? 999
                let errorUploadFileModel = DownloadFileModel(messageContentModel: nil, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                completion(nil, errorUploadFileModel)
            }
        }
    }
    
    
    // MARK: - Manage  Upload/Download  Image/File
    
    public func manageUpload(image:             Bool,
                             file:              Bool,
                             withUniqueId:      String,
                             withAction action: DownloaUploadAction,
                             completion:        @escaping (String, Bool) -> ()) {
        for (index, item) in uploadRequest.enumerated() {
            if item.uniqueId == withUniqueId {
                switch (action , image, file) {
                case (.suspend, _, _):
                    item.upload.suspend()
                    completion("upload image/file with this uniqueId: '\(withUniqueId)' had been Suspended", true)
                    
                case (.resume, _, _):
                    item.upload.resume()
                    completion("upload image/file with this uniqueId: '\(withUniqueId)' had been Resumed", true)
                    
                case (.cancel, true, false):
                    item.upload.cancel()
                    uploadRequest.remove(at: index)
                    Chat.cacheDB.deleteWaitUploadImages(uniqueId: withUniqueId)
                    completion("upload image with this uniqueId: '\(withUniqueId)' had been Canceled", true)
                    
                case (.cancel, false, true):
                    item.upload.cancel()
                    uploadRequest.remove(at: index)
                    Chat.cacheDB.deleteWaitUploadFiles(uniqueId: withUniqueId)
                    completion("upload file with this uniqueId: '\(withUniqueId)' had been Canceled", true)
                    
                default:
                    completion("Wrong situation to manage upload", false)
                }
            }
        }
    }
    
    
    public func manageDownload(withUniqueId:        String,
                               withAction action:   DownloaUploadAction,
                               completion:          @escaping (String, Bool) -> ()) {
        for (index, item) in downloadRequest.enumerated() {
            if item.uniqueId == withUniqueId {
                switch action {
                case .cancel:
                    item.download.cancel()
                    completion("download with this uniqueId '\(withUniqueId)' had been Canceled", true)
                    
                case .suspend:
                    item.download.suspend()
                    completion("download with this uniqueId '\(withUniqueId)' had been Suspended", true)
                    
                case .resume:
                    item.download.resume()
                    completion("download with this uniqueId '\(withUniqueId)' had been Resumed", true)
                    
                }
                downloadRequest.remove(at: index)
            }
        }
    }
    
    
    
}
