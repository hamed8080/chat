//
//
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
    
    
    
    public func isImageAvailableOnCache(inputModel imageInput:  GetImageRequest) -> Bool {
        if let isAvailable = Chat.cacheDB.isImageAvailable(hashCode: imageInput.hashCode) {
            return isAvailable
        } else {
            return false
        }
    }
    
    public func isFileAvailableOnCache(inputModel fileInput:  GetFileRequest) -> Bool {
        if let isAvailable = Chat.cacheDB.isFileAvailable(hashCode: fileInput.hashCode) {
            return isAvailable
        } else {
            return false
        }
    }
    
    public func isAvailableOnCache(inputModel fileInput:  GetFileRequest) -> Bool {
        if let isAvailable = Chat.cacheDB.isFileAvailable(hashCode: fileInput.hashCode) {
            return isAvailable
        } else {
            return false
        }
    }
    
    public func isAvailableOnCache(inputModel imageInput:  GetImageRequest) -> Bool {
        if let isAvailable = Chat.cacheDB.isImageAvailable(hashCode: imageInput.hashCode) {
            return isAvailable
        } else {
            return false
        }
    }
    
    
    public func isThumbnailAvailableOnCache(inputModel imageInput:  GetImageRequest) -> Bool {
        if let isAvailable = Chat.cacheDB.isThumbnailAvailable(hashCode: imageInput.hashCode) {
            return isAvailable
        } else {
            return false
        }
    }
    
    
    
    // MARK: - Get File
    /// GetFIle:
    /// get specific file.
    ///
    /// By calling this function, HTTP request of type (GET_FILE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetFileRequest" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (GetFileRequest)
    /// - parameter getCacheResponse:   (input) specify if you want to get cache response for this request (Bool?)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter progress:           (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Data?, UploadFileModel)
    /// - parameter cacheResponse:      (response) it will returns the response from CacheDB if user has enabled it. (UploadFileModel, String)
    public func getFile(inputModel getFileInput:    GetFileRequest,
                        getCacheResponse:           Bool?,
                        uniqueId:       @escaping (String) -> (),
                        progress:       @escaping (Float) -> (),
                        completion:     @escaping (Data?, DownloadFileModel) -> (),
                        cacheResponse:  @escaping (Data, DownloadFileModel) -> ()) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        var hasFileOntheCache = false
        
        // if cache is enabled by user, first return cache result to the user
        if (getCacheResponse ?? enableCache) {
            if let (cacheFileResult, filePath) = Chat.cacheDB.retrieveFileObject(hashCode: getFileInput.hashCode) {
                hasFileOntheCache = true
                let response = DownloadFileModel(messageContentModel:   cacheFileResult,
                                                 errorCode:             0,
                                                 errorMessage:          "",
                                                 hasError:              false)
                if FileManager.default.fileExists(atPath: filePath) {
                    let fileURL = URL(fileURLWithPath: filePath)
                    if let data = try? Data(contentsOf: fileURL) {
                        hasFileOntheCache = true
                        cacheResponse(data, response)
                    } else {
                        delegate?.chatError(errorCode: 1000,
                                            errorMessage: "cannot read file data from local path",
                                            errorResult: nil)
                    }
//                    do {
//                        let data = try Data(contentsOf: fileURL)
//                        hasFileOntheCache = true
//                        cacheResponse(data, response)
//                    } catch {
//                        fatalError("cannot get the fileData from imagPath")
//                    }
                }
            }
        }

        if (!hasFileOntheCache) || (getFileInput.serverResponse) {
            _ = checkIfDeviceHasFreeSpace(needSpaceInMB: deviecLimitationSpaceMB, turnOffTheCache: false)
            sendRequestToDownloadFile(withInputModel: getFileInput, progress: { (theProgress) in
                progress(theProgress)
            }) { (data, fileModel) in
                completion(data, fileModel)
            }
        }
        
    }
    
    private func sendRequestToDownloadFile(withInputModel getFileInput:   GetFileRequest,
                                           progress:       @escaping (Float) -> (),
                                           completion:     @escaping (Data?, DownloadFileModel) -> ()) {

        let url = "\(SERVICE_ADDRESSES.PODSPACE_FILESERVER_ADDRESS)\(SERVICES_PATH.DRIVE_DOWNLOAD_FILE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let headers:    HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        Networking.sharedInstance.download(fromUrl:         url,
                                           withMethod:      method,
                                           withHeaders:     headers,
                                           withParameters:  getFileInput.convertContentToParameters()
        , progress: { (myProgress) in
            progress(myProgress)
        }) { (fileDataResponse, responseHeader) in
            if let myFile = fileDataResponse {
                // save data comes from server to the Cache
                let fileName = responseHeader["name"].string
                let fileType = responseHeader["type"].string
                let fileSize = responseHeader["size"].int
                let theFinalFileName = "\(fileName ?? "default").\(fileType ?? "none")"
                let uploadFile = FileObject(hashCode:   getFileInput.hashCode,
//                                            id:         getFileInput.fileId,
                                            name:       theFinalFileName,
                                            size:       fileSize ?? myFile.count,
                                            type:       fileType)

                if self.enableCache {
                    if self.checkIfDeviceHasFreeSpace(needSpaceInMB: Int64(myFile.count / 1024), turnOffTheCache: true) {
                        Chat.cacheDB.saveFileObject(fileInfo: uploadFile, fileData: myFile, toLocalPath: self.localFileCustomPath)
                    }
                }

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
    
    
    // MARK: - Get Image
    /// GetImage:
    /// get specific image.
    ///
    /// By calling this function, HTTP request of type (GET_IMAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetImageRequest" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (GetImageRequest)
    /// - parameter getCacheResponse:   (input) specify if you want to get cache response for this request (Bool?)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter progress:           (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Data?, UploadImageModel)
    /// - parameter cacheResponse:      (response) it will returns the response from CacheDB if user has enabled it. (UploadImageModel, String)
    public func getImage(inputModel getImageInput:  GetImageRequest,
                         getCacheResponse:          Bool?,
                         uniqueId:      @escaping (String) -> (),
                         progress:      @escaping (Float) -> (),
                         completion:    @escaping (Data?, DownloadImageModel) -> (),
                         cacheResponse: @escaping (Data, DownloadImageModel) -> ()) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        var hasImageOnTheCache = false
        
        // if cache is enabled by user, first return cache result to the user
        if (getCacheResponse ?? enableCache) {
            if let (cacheImageResult, imagePath) = Chat.cacheDB.retrieveImageObject(hashCode:   getImageInput.hashCode) {
                let response = DownloadImageModel(messageContentModel:   cacheImageResult,
                                                  errorCode:             0,
                                                  errorMessage:          "",
                                                  hasError:              false)
                if FileManager.default.fileExists(atPath: imagePath) {
                    let imagURL = URL(fileURLWithPath: imagePath)
                    if let data = try? Data(contentsOf: imagURL) {
                        hasImageOnTheCache = true
                        cacheResponse(data, response)
                    } else {
                        delegate?.chatError(errorCode: 1000,
                                            errorMessage: "cannot read image data from local path",
                                            errorResult: nil)
                    }
//                    do {
//                        let data = try Data(contentsOf: imagURL)
//                        hasImageOnTheCache = true
//                        cacheResponse(data, response)
//                    } catch {
//                        fatalError("cannot get the fileData from imagPath")
//                    }
                }
            }
        }
        
        if (!hasImageOnTheCache) || (getImageInput.serverResponse) {
            _ = checkIfDeviceHasFreeSpace(needSpaceInMB: self.deviecLimitationSpaceMB, turnOffTheCache: false)
            sendRequestToDownloadImage(withInputModel: getImageInput, progress: { (theProgress) in
                progress(theProgress)
            }) { (data, imageModel) in
                completion(data, imageModel)
            }
        }
        
    }
    
    public func getThumbnailImage(inputModel getImageInput:  GetImageRequest,
                                  getCacheResponse:          Bool?,
                                  uniqueId:      @escaping (String) -> (),
                                  progress:      @escaping (Float) -> (),
                                  completion:    @escaping (Data?, DownloadImageModel) -> (),
                                  cacheResponse: @escaping (Data, DownloadImageModel) -> ()) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        var hasImageOnTheCache = false
        
        // if cache is enabled by user, first return cache result to the user
        if (getCacheResponse ?? enableCache) {
            if let (cacheImageResult, imagePath) = Chat.cacheDB.retrieveImageThumbnailObject(hashCode:   getImageInput.hashCode) {
                let response = DownloadImageModel(messageContentModel:   cacheImageResult,
                                                  errorCode:             0,
                                                  errorMessage:          "",
                                                  hasError:              false)
                if FileManager.default.fileExists(atPath: imagePath) {
                    let imagURL = URL(fileURLWithPath: imagePath)
                    if let data = try? Data(contentsOf: imagURL) {
                        hasImageOnTheCache = true
                        cacheResponse(data, response)
                    } else {
                        delegate?.chatError(errorCode: 1000,
                                            errorMessage: "cannot read image data from local path",
                                            errorResult: nil)
                    }
                }
            }
        }
        let input = GetImageRequest(hashCode:   getImageInput.hashCode,
                                    quality:    0.123,
                                    crop:       getImageInput.crop,
                                    size:       getImageInput.size,
                                    serverResponse: getImageInput.serverResponse)
        if (!hasImageOnTheCache) || (getImageInput.serverResponse) {
            _ = checkIfDeviceHasFreeSpace(needSpaceInMB: self.deviecLimitationSpaceMB, turnOffTheCache: false)
            sendRequestToDownloadImage(withInputModel: input, progress: { (theProgress) in
                progress(theProgress)
            }) { (data, imageModel) in
                completion(data, imageModel)
            }
        }
        
    }
    
    private func sendRequestToDownloadImage(withInputModel getImageInput: GetImageRequest,
                                            progress:      @escaping (Float) -> (),
                                            completion:    @escaping (Data?, DownloadImageModel) -> ()) {
        
        let url = "\(SERVICE_ADDRESSES.PODSPACE_FILESERVER_ADDRESS)\(SERVICES_PATH.DRIVE_DOWNLOAD_IMAGE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let headers:    HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        Networking.sharedInstance.download(fromUrl:         url,
                                           withMethod:      method,
                                           withHeaders:     headers,
                                           withParameters:  getImageInput.convertContentToParameters()
        , progress: { (myProgress) in
            progress(myProgress)
        }) { (imageDataResponse, responseHeader)  in
            if let myData = imageDataResponse {
                // save data comes from server to the Cache
                let fileName = responseHeader["name"].string
                let fileType = responseHeader["type"].string
                let fileSize = responseHeader["size"].int
                let theFinalFileName = "\(fileName ?? "default").\(fileType ?? "none")"
                let uploadImage = ImageObject(actualHeight: nil,
                                              actualWidth:  nil,
                                              hashCode:     getImageInput.hashCode,
                                              height:       nil,
//                                              id:           getImageInput.imageId,
                                              name:         theFinalFileName,
                                              size:         fileSize ?? myData.count,
                                              width:        nil)
                
                if self.enableCache {
                    if self.checkIfDeviceHasFreeSpace(needSpaceInMB: Int64(myData.count / 1024), turnOffTheCache: true) {
                        if getImageInput.quality == 0.123 {
                            Chat.cacheDB.saveThumbnailImageObject(imageInfo: uploadImage, imageData: myData, toLocalPath: self.localImageCustomPath)
                        } else {
                            Chat.cacheDB.saveImageObject(imageInfo: uploadImage, imageData: myData, toLocalPath: self.localImageCustomPath)
                        }
                        
                    }
                }
                
                let uploadImageModel = DownloadImageModel(messageContentModel: uploadImage, errorCode: 0, errorMessage: "", hasError: false)
                completion(myData, uploadImageModel)
            } else {
                let errorUploadImageModel = DownloadImageModel(messageContentModel: nil,
                                                               errorCode:           responseHeader["errorCode"].int ?? 999,
                                                               errorMessage:        responseHeader["errorMessage"].string ?? "",
                                                               hasError:            responseHeader["hasError"].bool ?? false)
                completion(nil, errorUploadImageModel)
            }
        }
    }
    
    
    // MARK: - Upload File
    /// UploadFile:
    /// upload some file.
    ///
    /// By calling this function, HTTP request of type (UPLOAD_FILE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UploadFileRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UploadFileRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter progress:   (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (UploadFileModel)
    public func uploadFile(inputModel uploadFileInput: UploadFileRequest,
                           uniqueId:        @escaping (String) -> (),
                           progress:        @escaping (Float) -> (),
                           completion:      @escaping callbackTypeAlias) {

        log.verbose("Try to upload file with this parameters: \n \(uploadFileInput)", context: "Chat")

        uniqueId(uploadFileInput.uniqueId)

        if (enableCache) {
            /*
                seve this upload image on the Cache Wait Queue,
                so if there was an situation that response of the server to this uploading doesn't come, then we know that our upload request didn't sent correctly
                and we will send this Queue to user on the GetHistory request,
                now user knows which upload requests didn't send correctly, and can handle them
                */
            let messageObjectToSendToQueue = QueueOfWaitUploadFilesModel(dataToSend:    uploadFileInput.dataToSend,
                                                                         fileExtension: uploadFileInput.fileExtension,
                                                                         fileName:      uploadFileInput.fileName,
                                                                         fileSize:      uploadFileInput.fileSize,
                                                                         isPublic:      uploadFileInput.isPublic,
                                                                         mimeType:      uploadFileInput.mimeType,
                                                                         originalName:  uploadFileInput.originalName,
                                                                         userGroupHash: uploadFileInput.userGroupHash,
                                                                         typeCode:      uploadFileInput.typeCode,
                                                                         uniqueId:      uploadFileInput.uniqueId)
            Chat.cacheDB.saveUploadFileToWaitQueue(file: messageObjectToSendToQueue)
        }

        var url = "\(SERVICE_ADDRESSES.PODSPACE_FILESERVER_ADDRESS)"
        if let _ = uploadFileInput.userGroupHash {
            url += "\(SERVICES_PATH.PODSPACE_PUBLIC_UPLOAD_FILE.rawValue)"
        } else {
            url += "\(SERVICES_PATH.PODSPACE_UPLOAD_FILE.rawValue)"
        }
        
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
                                                       userGroupHash:   uploadFileInput.userGroupHash,
                                                       uniqueId:        uploadFileInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadedEM)
                progress(myProgress)
        }) { (response) in
            let myResponse: JSON = response as! JSON
            
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["message"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                
                if self.enableCache {
                    // save data comes from server to the Cache
                    let uploadFileObject = FileObject(messageContent: resultData)
                    Chat.cacheDB.saveFileObject(fileInfo: uploadFileObject, fileData: uploadFileInput.dataToSend, toLocalPath: self.localFileCustomPath)
                    let getFileRequest = GetFileRequest(//fileId:         uploadFileObject.id,
                                                        hashCode:       uploadFileObject.hashCode,
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
                                                        userGroupHash:        uploadFileInput.userGroupHash,
                                                        uniqueId:        uploadFileInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadedEM)
                
                let uploadFileModel = UploadFileResponse(messageContentJSON: resultData,
                                                         errorCode:         errorCode,
                                                         errorMessage:      errorMessage,
                                                         hasError:          hasError)
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
                                                          userGroupHash:    uploadFileInput.userGroupHash,
                                                          uniqueId:         uploadFileInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadErrorEM)
                let errorResponse = UploadFileResponse(messageContentJSON:  nil,
                                                       errorCode:           errorCode,
                                                       errorMessage:        errorMessage,
                                                       hasError:            hasError)
                completion(errorResponse)
            }
        }
    }
    
    
    // MARK: - Upload Image
    /// UploadImage:
    /// upload some image.
    ///
    /// By calling this function, HTTP request of type (UPLOAD_IMAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UploadImageRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UploadImageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter progress:   (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (UploadImageModel)
    public func uploadImage(inputModel uploadImageInput:   UploadImageRequest,
                            uniqueId:       @escaping (String) -> (),
                            progress:       @escaping (Float) -> (),
                            completion:     @escaping callbackTypeAlias) {
        
        log.verbose("Try to upload image with this parameters: \n \(uploadImageInput)", context: "Chat")
        
        uniqueId(uploadImageInput.uniqueId)
        
        if (enableCache) {
            /**
             seve this upload image on the Cache Wait Queue,
             so if there was an situation that response of the server to this uploading doesn't come, then we know that our upload request didn't sent correctly
             and we will send this Queue to user on the GetHistory request,
             now user knows which upload requests didn't send correctly, and can handle them
             */
            let messageObjectToSendToQueue = QueueOfWaitUploadImagesModel(dataToSend:       uploadImageInput.dataToSend,
                                                                          fileExtension:    uploadImageInput.fileExtension,
                                                                          fileName:         uploadImageInput.fileName,
                                                                          fileSize:         uploadImageInput.fileSize,
                                                                          isPublic:         uploadImageInput.isPublic,
                                                                          mimeType:         uploadImageInput.mimeType,
                                                                          originalName:     uploadImageInput.originalName,
                                                                          userGroupHash:    uploadImageInput.userGroupHash,
                                                                          xC:               uploadImageInput.xC,
                                                                          yC:               uploadImageInput.yC,
                                                                          hC:               uploadImageInput.hC,
                                                                          wC:               uploadImageInput.wC,
                                                                          typeCode:         uploadImageInput.typeCode,
                                                                          uniqueId:         uploadImageInput.uniqueId)
            Chat.cacheDB.saveUploadImageToWaitQueue(image: messageObjectToSendToQueue)
        }
        
        var url = "\(SERVICE_ADDRESSES.PODSPACE_FILESERVER_ADDRESS)"
        if let _ = uploadImageInput.userGroupHash {
            url += "\(SERVICES_PATH.PODSPACE_PUBLIC_UPLOAD_IMAGE.rawValue)"
        } else {
            url += "\(SERVICES_PATH.PODSPACE_UPLOAD_IMAGE.rawValue)"
        }
        
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
                                                       userGroupHash:   uploadImageInput.userGroupHash,
                                                       uniqueId:        uploadImageInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadedEM)
                progress(myProgress)
        }) { (response) in
            let myResponse: JSON = response as! JSON
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["message"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                
                if self.enableCache {
                    // save data comes from server to the Cache
                    let uploadImageFile = ImageObject(messageContent: resultData)
                    Chat.cacheDB.saveImageObject(imageInfo: uploadImageFile, imageData: uploadImageInput.dataToSend, toLocalPath: self.localImageCustomPath)
                    let getImageRequest = GetImageRequest(//imageId:  uploadImageFile.id,
                                                          hashCode: uploadImageFile.hashCode,
                                                          quality:  nil,
                                                          crop:     nil,
                                                          size:     nil,
                                                          serverResponse: true)
                    self.sendRequestToDownloadImage(withInputModel: getImageRequest,
                                                    progress:       { _ in },
                                                    completion:     { (_, _) in })
                    Chat.cacheDB.deleteWaitUploadImages(uniqueId: uploadImageInput.uniqueId)
                }
                
                let fileInfo = FileInfo(fileName: uploadImageInput.fileName,
                                        fileSize: uploadImageInput.fileSize)
                let fUploadedEM = FileUploadEventModel(type:            FileUploadEventTypes.UPLOADED,
                                                       errorCode:       errorCode,
                                                       errorMessage:    errorMessage,
                                                       errorEvent:      nil,
                                                       fileInfo:        fileInfo,
                                                       fileObjectData:  nil,
                                                       progress:        uploadProgress,
                                                       userGroupHash:   uploadImageInput.userGroupHash,
                                                       uniqueId:        uploadImageInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadedEM)
                
                let uploadImageModel = UploadImageResponse(messageContentJSON:  resultData,
                                                           errorCode:           errorCode,
                                                           errorMessage:        errorMessage,
                                                           hasError:            hasError)
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
                                                          userGroupHash:    uploadImageInput.userGroupHash,
                                                          uniqueId:         uploadImageInput.uniqueId)
                Chat.sharedInstance.delegate?.fileUploadEvents(model: fUploadErrorEM)
                let errorResponse = UploadImageResponse(messageContentJSON: nil,
                                                        errorCode:          errorCode,
                                                        errorMessage:       errorMessage,
                                                        hasError:           hasError)
                completion(errorResponse)
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
    
    
    // MARK: - Get Local Storage Size
    
    /// GetDeviceFreeSpace:
    /// get Device free space as it shows on itunes.
    ///
    /// By calling this function, we will get the device free space on the Device
    ///
    /// Inputs:
    /// - this method has no inputs
    ///
    /// Outputs:
    /// -
    ///
    public func getDeviceFreeSpace() {
        
    }
    
    /// GetLocalUsedSpace:
    /// get device local used space Storage
    ///
    /// By calling this function, we will get the device storage that chat package reserved for its data
    ///
    /// Inputs:
    /// - this method has no inputs
    ///
    /// Outputs:
    /// - it has only one return value as Int that represents data as Byte
    ///
    public func getLocalUsedSpace() -> Int {
        return getLocalImageFolderUsedSpace() + getLocalFilesFolderUsedSpace()
    }
    
    /// GetLocalImageUsedSpace:
    /// get device local image used space Storage
    ///
    /// By calling this function, we will get the image storage that chat package reserved for its data
    ///
    /// Inputs:
    /// - this method has no inputs
    ///
    /// Outputs:
    /// - it has only one return value as Int that represents data as Byte
    ///
    public func getLocalImageFolderUsedSpace() -> Int {
        return Chat.cacheDB.retrieveAllImagesSize()
    }
    
    /// GetLocalFileUsedSpace:
    /// get device local file used space Storage
    ///
    /// By calling this function, we will get the file storage that chat package reserved for its data
    ///
    /// Inputs:
    /// - this method has no inputs
    ///
    /// Outputs:
    /// - it has only one return value as Int that represents data as Byte
    ///
    public func getLocalFilesFolderUsedSpace() -> Int {
        return Chat.cacheDB.retrieveAllFilesSize()
    }
    
    
    // MARK: - Delete Local Storage Folders
    
    /// DeleteLocalImages:
    /// delete Local  Image and its related cache data
    ///
    /// By calling this function, we will delete all Images from Storage and tables that holds information of them
    ///
    /// Inputs:
    /// - this method has no inputs
    ///
    /// Outputs:
    /// - this method has no output
    public func deleteLocalImages() {
        Chat.cacheDB.deleteAllImages()
    }
    
    /// DeleteLocalFiles:
    /// delete Local  Files and its related cache data
    ///
    /// By calling this function, we will delete all Files from Storage and tables that holds information of them
    ///
    /// Inputs:
    /// - this method has no inputs
    ///
    /// Outputs:
    /// - this method has no output
    public func deleteLocalFiles() {
        Chat.cacheDB.deleteAllFiles()
    }
    
    /// DeleteALlLocalContent:
    /// delete Local Image and Files and its related cache data
    ///
    /// By calling this function, we will delete all Images and File from Storage and tables that holds information of them
    ///
    /// Inputs:
    /// - this method has no inputs
    ///
    /// Outputs:
    /// - this method has no output
    public func deleteAllLocalContent() {
        deleteLocalImages()
        deleteLocalFiles()
    }
    
    /// DeleteCache:
    /// delete all cache data
    ///
    /// By calling this function, we will delete all Cache and Storage data that ChatSDK saved earlier
    ///
    /// Inputs:
    /// - this method has no inputs
    ///
    /// Outputs:
    /// - this method has no output
    public func deleteCache() {
        Chat.cacheDB.deleteCacheData()
    }
    
}
