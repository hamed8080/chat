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
    /*
     UploadImage:
     upload some image.
     
     By calling this function, HTTP request of type (UPLOAD_IMAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - fileExtension:
     - fileName:   name of the image
     - fileSize:
     - threadId:
     - uniqueId:
     - originalFileName:
     - xC:
     - yC:
     - hC:
     - wC:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func uploadImage(uploadImageInput:   UploadImageRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            progress:           @escaping (Float) -> (),
                            completion:         @escaping callbackTypeAlias) {
        log.verbose("Try to upload image with this parameters: \n \(uploadImageInput)", context: "Chat")
        
        let uploadUniqueId = uploadImageInput.requestUniqueId ?? generateUUID()
        
        if enableCache {
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
                                                                          uniqueId:           uploadUniqueId,
                                                                          xC:                 uploadImageInput.xC,
                                                                          yC:                 uploadImageInput.yC,
                                                                          hC:                 uploadImageInput.hC,
                                                                          wC:                 uploadImageInput.wC)
            Chat.cacheDB.saveUploadImageToWaitQueue(image: messageObjectToSendToQueue)
        }
        
        var fileName:           String  = ""
        //        var fileType:           String  = ""
        //        var fileSize:           Int     = 0
        var fileExtension:      String  = ""
        
        var uploadFileData: JSON = [:]
        
        uploadFileData["uniqueId"] = JSON(uploadUniqueId)
        uniqueId(uploadUniqueId)
        
        if let myFileExtension = uploadImageInput.fileExtension {
            fileExtension = myFileExtension
        }
        
        if let myFileName = uploadImageInput.fileName {
            fileName = myFileName
        } else {
            let myFileName = "\(generateUUID()).\(fileExtension)"
            fileName = myFileName
        }
        
        if let myFileSize = uploadImageInput.fileSize {
            uploadFileData["fileSize"] = JSON(myFileSize)
        }
        
        if let threadId = uploadImageInput.threadId {
            uploadFileData["threadId"] = JSON(threadId)
        }
        
        if let myOriginalFileName = uploadImageInput.originalFileName {
            uploadFileData["originalFileName"] = JSON(myOriginalFileName)
        }
        
        uploadFileData["fileName"] = JSON(fileName)
        
        if let xC = uploadImageInput.xC {
            uploadFileData["xC"] = JSON(xC)
        }
        
        if let yC = uploadImageInput.yC {
            uploadFileData["yC"] = JSON(yC)
        }
        
        if let hC = uploadImageInput.hC {
            uploadFileData["hC"] = JSON(hC)
        }
        
        if let wC = uploadImageInput.wC {
            uploadFileData["wC"] = JSON(wC)
        }
        
        /*
         *  + data:
         *      -image:             String
         *      -fileName:          String
         *      -fileSize:          Int
         *      -threadId:          Int
         *      -uniqueId:          String
         *      -originalFileName:  String
         */
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.UPLOAD_IMAGE.rawValue)"
//        let method:     HTTPMethod  = HTTPMethod.post
        let headers:    HTTPHeaders = ["_token_": token, "_token_issuer_": "1", "Content-type": "multipart/form-data"]
        let parameters: Parameters = ["fileName": fileName]
        
        
        Networking.sharedInstance.upload(toUrl:             url,
                                         withHeaders:       headers,
                                         withParameters:    parameters,
                                         isImage:           true,
                                         isFile:            false,
                                         dataToSend:        uploadImageInput.dataToSend,
                                         requestUniqueId:   uploadFileData["uniqueId"].stringValue,
                                         progress: { (myProgress) in
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
                    let uploadImageFile = UploadImage(messageContent: resultData)
                    Chat.cacheDB.saveUploadImage(imageInfo: uploadImageFile, imageData: uploadImageInput.dataToSend)
                    Chat.cacheDB.deleteWaitUploadImages(uniqueId: uploadUniqueId)
                }
                
                let uploadImageModel = UploadImageModel(messageContentJSON: resultData, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                
                completion(uploadImageModel)
            }
        }
        
    }
    
    
    /*
     UploadFile:
     upload some file.
     
     By calling this function, HTTP request of type (UPLOAD_FILE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - fileExtension:
     - fileName:   name of the image
     - fileSize:
     - threadId:
     - uniqueId:
     - originalFileName:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func uploadFile(uploadFileInput: UploadFileRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           progress:        @escaping (Float) -> (),
                           completion:      @escaping callbackTypeAlias) {
        log.verbose("Try to upload file with this parameters: \n \(uploadFileInput)", context: "Chat")
        
        let uploadUniqueId = uploadFileInput.requestUniqueId ?? generateUUID()
        
        if enableCache {
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
                                                                         requestUniqueId:   uploadUniqueId)
            Chat.cacheDB.saveUploadFileToWaitQueue(file: messageObjectToSendToQueue)
        }
        
        
        
        var fileName:           String  = ""
        //        var fileType:           String  = ""
        var fileSize:           Int     = 0
        var fileExtension:      String  = ""
        
        var uploadThreadId:     Int     = 0
        var originalFileName:   String  = ""
        
        var uploadFileData: JSON = [:]
        
        uploadFileData["uniqueId"] = JSON(uploadUniqueId)
        uniqueId(uploadUniqueId)
        
        if let myFileExtension = uploadFileInput.fileExtension {
            fileExtension = myFileExtension
        }
        
        if let myFileName = uploadFileInput.fileName {
            fileName = myFileName
        } else {
            let myFileName = "\(generateUUID()).\(fileExtension)"
            fileName = myFileName
        }
        
        if let myFileSize = uploadFileInput.fileSize {
            fileSize = myFileSize
        }
        
        if let threadId = uploadFileInput.threadId {
            uploadThreadId = threadId
        }
        
        if let myOriginalFileName = uploadFileInput.originalFileName {
            originalFileName = myOriginalFileName
        } else {
            originalFileName = fileName
        }
        
        uploadFileData["fileName"] = JSON(fileName)
        uploadFileData["threadId"] = JSON(uploadThreadId)
        uploadFileData["fileSize"] = JSON(fileSize)
        //        uploadFileData["uniqueId"] = JSON(uploadUniqueId)
        uploadFileData["originalFileName"] = JSON(originalFileName)
        
        
        /*
         *  + data:
         *      -file:              String
         *      -fileName:          String
         *      -fileSize:          Int
         *      -threadId:          Int
         *      -uniqueId:          String
         *      -originalFileName:  String
         */
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.UPLOAD_FILE.rawValue)"
//        let method:     HTTPMethod  = HTTPMethod.post
        let headers:    HTTPHeaders = ["_token_": token, "_token_issuer_": "1", "Content-type": "multipart/form-data"]
        let parameters: Parameters = ["fileName": fileName]
        
        
        Networking.sharedInstance.upload(toUrl: url,
                                         withHeaders: headers,
                                         withParameters: parameters,
                                         isImage: false,
                                         isFile: true,
                                         dataToSend: uploadFileInput.dataToSend,
                                         requestUniqueId: uploadFileData["uniqueId"].stringValue,
                                         progress: { (myProgress) in
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
                    let uploadFileFile = UploadFile(messageContent: resultData)
                    Chat.cacheDB.saveUploadFile(fileInfo: uploadFileFile, fileData: uploadFileInput.dataToSend)
                    Chat.cacheDB.deleteWaitUploadFiles(uniqueId: uploadUniqueId)
                }
                
                let uploadFileModel = UploadFileModel(messageContentJSON:   resultData,
                                                      errorCode:            errorCode,
                                                      errorMessage:         errorMessage,
                                                      hasError:             hasError)
                
                completion(uploadFileModel)
            }
        }
        
    }
    
    
    // MARK: - Get Image/File
    /*
     GetImage:
     get specific image.
     
     By calling this function, HTTP request of type (GET_IMAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as 'GetImageRequestModel' Model which are:
     - actual:
     - downloadable:
     - hashCode:
     - height:
     - imageId:
     - width:
     
     + Outputs:
     It has 3 callbacks as response:
     1- progress:       The progress of the downloading file as a number between 0 and 1.   (Float)
     2- completion:     when the file completely downloaded, it will sent to client as 'UploadImageModel' model
     3- cacheResponse:  If the file was already avalable on the cache, and aslso client wants to get cache result, it will send it as 'UploadImageModel' model
     */
    public func getImage(getImageInput: GetImageRequestModel,
                         uniqueId:      @escaping (String) -> (),
                         progress:      @escaping (Float) -> (),
                         completion:    @escaping (Data?, UploadImageModel) -> (),
                         cacheResponse: @escaping (UploadImageModel, String) -> ()) {
        
        let theUniqueId = generateUUID()
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        var parameters: Parameters = ["hashCode": getImageInput.hashCode,
                                      "imageId": getImageInput.imageId]
        if let theActual = getImageInput.actual {
            parameters["actual"] = JSON(theActual)
        }
        if let theDownloadable = getImageInput.downloadable {
            parameters["downloadable"] = JSON(theDownloadable)
        }
        if let theHeight = getImageInput.height {
            parameters["height"] = JSON(theHeight)
        }
        if let theWidth = getImageInput.width {
            parameters["width"] = JSON(theWidth)
        }
        
        uniqueId(theUniqueId)
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            if let (cacheImageResult, imagePath) = Chat.cacheDB.retrieveUploadImage(hashCode: getImageInput.hashCode, imageId: getImageInput.imageId) {
                cacheResponse(cacheImageResult, imagePath)
            }
        }
        
        
        // IMPROVMENT NEEDED:
        // maybe if i had the answer from cache, i have to ignore the bottom code that request to server to get file again!!
        // so this code have to only request file if it couldn't find the file on the cache
        
        Networking.sharedInstance.download(toUrl: url,
                                           withMethod: method,
                                           withHeaders: nil,
                                           withParameters: parameters,
                                           progress: { (myProgress) in
                                            progress(myProgress)
        }) { (imageDataResponse, responseHeader)  in
            if let myData = imageDataResponse {
                // save data comes from server to the Cache
                let fileName = responseHeader["name"].string
                let fileType = responseHeader["type"].string
                let theFinalFileName = "\(fileName ?? "default").\(fileType ?? "none")"
                let uploadImage = UploadImage(actualHeight: nil,
                                              actualWidth:  nil,
                                              hashCode:     getImageInput.hashCode,
                                              height:       getImageInput.height,
                                              id:           getImageInput.imageId,
                                              name:         theFinalFileName,
                                              width:        getImageInput.width)
                
                if self.enableCache {
                    Chat.cacheDB.saveUploadImage(imageInfo: uploadImage, imageData: myData)
                }
                
                let uploadImageModel = UploadImageModel(messageContentModel: uploadImage, errorCode: 0, errorMessage: "", hasError: false)
                completion(myData, uploadImageModel)
            } else {
                let hasError = responseHeader["hasError"].bool ?? false
                let errorMessage = responseHeader["errorMessage"].string ?? ""
                let errorCode = responseHeader["errorCode"].int ?? 999
                let errorUploadImageModel = UploadImageModel(messageContentModel: nil, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                completion(nil, errorUploadImageModel)
            }
        }
        
    }
    
    
    /*
     GetFIle:
     get specific file.
     
     By calling this function, HTTP request of type (GET_FILE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as 'GetFileRequestModel' Model which are:
     - downloadable:
     - fileId:
     - hashCode:
     
     + Outputs:
     It has 3 callbacks as response:
     1- progress:       The progress of the downloading file as a number between 0 and 1.   (Float)
     2- completion:     when the file completely downloaded, it will sent to client as 'UploadFileModel' model
     3- cacheResponse:  If the file was already avalable on the cache, and aslso client wants to get cache result, it will send it as 'UploadFileModel' model
     */
    public func getFile(getFileInput:   GetFileRequestModel,
                        uniqueId:       @escaping (String) -> (),
                        progress:       @escaping (Float) -> (),
                        completion:     @escaping (Data?, UploadFileModel) -> (),
                        cacheResponse:  @escaping (UploadFileModel, String) -> ()) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        var parameters: Parameters = ["hashCode": getFileInput.hashCode,
                                      "fileId": getFileInput.fileId]
        
        if let theDownloadable = getFileInput.downloadable {
            parameters["downloadable"] = JSON(theDownloadable)
        }
        
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            if let (cacheFileResult, imagePath) = Chat.cacheDB.retrieveUploadFile(fileId: getFileInput.fileId, hashCode: getFileInput.hashCode) {
                cacheResponse(cacheFileResult, imagePath)
            }
        }
        
        
        // IMPROVMENT NEEDED:
        // maybe if i had the answer from cache, i have to ignore the bottom code that request to server to get file again!!
        // so this code have to only request file if it couldn't find the file on the cache
        
        Networking.sharedInstance.download(toUrl: url,
                                           withMethod: method,
                                           withHeaders: nil,
                                           withParameters: parameters,
                                           progress: { (myProgress) in
                                            progress(myProgress)
        }) { (fileDataResponse, responseHeader) in
            if let myFile = fileDataResponse {
                // save data comes from server to the Cache
                let fileName = responseHeader["name"].string
                let fileType = responseHeader["type"].string
                let theFinalFileName = "\(fileName ?? "default").\(fileType ?? "none")"
                let uploadFile = UploadFile(hashCode: getFileInput.hashCode, id: getFileInput.fileId, name: theFinalFileName)
                Chat.cacheDB.saveUploadFile(fileInfo: uploadFile, fileData: myFile)
                
                let uploadFileModel = UploadFileModel(messageContentModel: uploadFile, errorCode: 0, errorMessage: "", hasError: false)
                
                completion(myFile, uploadFileModel)
            } else {
                let hasError = responseHeader["hasError"].bool ?? false
                let errorMessage = responseHeader["errorMessage"].string ?? ""
                let errorCode = responseHeader["errorCode"].int ?? 999
                let errorUploadFileModel = UploadFileModel(messageContentModel: nil, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
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
