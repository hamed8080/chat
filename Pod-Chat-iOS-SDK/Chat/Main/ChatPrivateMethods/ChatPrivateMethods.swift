//
//  ChatPrivateMethods.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import Alamofire
import SwiftyJSON
import SwiftyBeaver

// MARK: -
// MARK: - Private Methods:

extension Chat {
    
    /*
     *  Get deviceId with token:
     *
     *  + Access:
     *      - private
     *
     *  + Inputs:
     *      - this method has no prameters as input
     *
     *  + Outputs:
     *      - it will return the deviceId as a String as a callback
     */
    func getDeviceIdWithToken(completion: @escaping (String) -> ()) {
        /*
         *  -> send a .get request to ssoHost server to get all user registered devices
         *
         *  -> get response as String
         *  -> convert String to Data
         *  -> convert Data to JSON
         *      + JSON contains array of objects:
         *          - total:    Int
         *          - size:     Int
         *          - offset:   Int
         *          + devices:
         *              [
         *                  - agent:            String  (conrains user device details)
         *                  - browserVersion:   String  (ex: "Chrome")
         *                  - current:          Bool    (ex: false)
         *                  - deviceType:       String  (ex: "Desktop")
         *                  - id:               Int     (ex: 12209)
         *                  - ip:               String  (ex: "172.16.107.106")
         *                  - language:         String  (ex: "fa")
         *                  - lastAccessTime:   Int     (ex: 1548070459111)
         *                  + location:         {}
         *                  - os:               String  (ex: "Win10")
         *                  - osVersion:        String  (ex: "10.0")
         *                  - uid:              String  (ex: "a4c812ba4cea8b01bef58ac65c3a6094")
         *              ]
         *
         *  -> loop throuth the "devices" to find an object which its "current" value is equal to "true"
         *      (which means this is the current device that user is using right now)
         *      (actualy we have to find one object that has this condition)
         *  -> get the "uid" value from this object and pass it to the caller as completion
         *      (its the user deviceId)
         *
         *
         */
        
        let url = ssoHost + SERVICES_PATH.SSO_DEVICES.rawValue
        let method: HTTPMethod = .get
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        Alamofire.request(url, method: method, parameters: nil, headers: headers).responseString { (response) in
            
            // check if the result respons is success
            if response.result.isSuccess {
                let responseStr: String = response.result.value!
                // convert String to Data
                if let dataFromMsgString = responseStr.data(using: .utf8, allowLossyConversion: false) {
                    
                    var msg: JSON
                    do {
                        // convert Data to JSON
                        msg = try JSON(data: dataFromMsgString)
                    } catch {
                        fatalError("Cannot convert Data to JSON")
                    }
                    
                    // loop through devices
                    if let devices = msg["devices"].array {
                        for device in devices {
                            // check if we can found user current device
                            if device["current"].bool == true {
                                completion(device["uid"].stringValue)
                                break
                            }
                        }
                        if (self.deviceId == nil || (self.deviceId == "")) {
                            // if deviceId is nil, we will send an Error Event to client
                            self.delegate?.chatError(errorCode:     6000,
                                                     errorMessage:  CHAT_ERRORS.err6000.rawValue,
                                                     errorResult:   nil)
                        }
                    } else {
                        // if server response has no array value of devices, we will send an Error Event to client
                        self.delegate?.chatError(errorCode:     6001,
                                                 errorMessage:  CHAT_ERRORS.err6001.rawValue,
                                                 errorResult:   nil)
                    }
                    
                }
                
                
            } else if let error = response.error {
                log.error("Response of getDeviceIdWithToken is Failed)", context: "Chat")
                self.delegate?.chatError(errorCode:     6200,
                                         errorMessage:  "\(CHAT_ERRORS.err6200.rawValue): \(error)",
                                         errorResult:   error.localizedDescription)
            }
            
        }
        
        // last implementation of this function was using the httpRequest function that will deprecate because of complexity that comes with it over time.
        /*
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: nil, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { (myResponse) in
            let responseStr: String = myResponse as! String
         
            if let dataFromMsgString = responseStr.data(using: .utf8, allowLossyConversion: false) {
                // get currrent user deviceIdresponseStr
                var msg: JSON
                do {
                    msg = try JSON(data: dataFromMsgString)
                } catch {
                    fatalError()
                }
                
                if let devices = msg["devices"].array {
                    for device in devices {
                        if device["current"].bool == true {
                            completion(device["uid"].stringValue)
                            break
                        }
                    }
                    if (self.deviceId == nil || (self.deviceId == "")) {
                        self.delegate?.chatError(errorCode: 6000, errorMessage: CHAT_ERRORS.err6000.rawValue, errorResult: nil)
                    }
                } else {
                    self.delegate?.chatError(errorCode: 6001, errorMessage: CHAT_ERRORS.err6001.rawValue, errorResult: nil)
                }
                
            }
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_  in }
        */
        
    }
    

    /*
     *  Handshake with SSO to get user's keys:
     *
     * get the key (for Encrypt and Decrypt the Cache) from SSO
     *
     *  + Access:
     *      - private
     *
     *  + Inputs:
     *      - keyAlgorithm: String?
     *      - keySize:      Int?
     *
     *  + Outputs:
     *      - JSON (as completion handler)
     *
     */
    // TODO: save the new key into the Cache
    func generateEncryptionKey(keyAlgorithm: String?, keySize: Int?, completion: @escaping (JSON)->()) {
        /*
         *  -> send a .post request to the SSO server to generate and then get the key
         *
         *  -> get response as String
         *  -> convert String to Data
         *  -> convert Data to JSON
         *      + JSON contains this object:
         *          - algorithm:            String  (ex: "AES")
         *          - expires_in:           Int     (ex: 315360000)
         *          - keyFormat:            String  (ex: "base64")
         *          - keyId:                String  (ex: "18294d3013f61562669359")
         *          - secretKey:            String  (ex: "8nBxSBvghRaBpwPH8ZbA1bqUa7K\/Hbr5EH5Ab1WSJJY=")
         *          + device:
         *              - agent:            String  (ex: "Mozilla\/5.0 (X11; Linux x86_64) Appl ....")
         *              - browser:          String  (ex: "Chrome")
         *              - browserVersion:   String  (ex: "59")
         *              - current:          Bool    (ex: false)
         *              - deviceType:       String  (ex: "Desktop")
         *              - id:               Int     (ex: 10368)
         *              - ip:               String  (ex: "172.16.106.42")
         *              - lastAccessTime:   Int     (ex: 1551613854000)
         *              + location:         {}
         *              - os:               String  (ex: "Linux")
         *              - uid:              String  (ex: "94af0c8f381deeb7aa28a85c473641c1-Reza")
         *          + user:
         *              - family_name:          String  (ex: "Reza")
         *              - given_name:           String  (ex: "Irani")
         *              - id:                   Int     (ex: 5098)
         *              - preferred_username:   String  (ex: "Reza")
         *
         */
        
        let url = SERVICE_ADDRESSES.SSO_ADDRESS + SERVICES_PATH.SSO_GENERATE_KEY.rawValue
        let method: HTTPMethod = .post
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["validity":       10 * 365 * 24 * 60 * 60,      // 10 years
                                  "renew":          "true",
                                  "keyAlgorithm":   keyAlgorithm ?? "aes",
                                  "keySize":        keySize ?? 256]
        
        Alamofire.request(url, method: method, parameters: params, headers: headers).responseString { (response) in
            
            if response.result.isSuccess {
                let responseStr: String = response.result.value!
                // convert String to Data
                if let dataFromMsgString = responseStr.data(using: .utf8, allowLossyConversion: false) {
                    
                    var msg: JSON
                    do {
                        // convert Data to JSON
                        msg = try JSON(data: dataFromMsgString)
                    } catch {
                        fatalError("Cannot convert Data to JSON")
                    }
                    print("***********2: \(msg)")
                    let myJson: JSON = ["hasError":     false,
                                        "errorCode":    0,
                                        "errorMessage": "",
                                        "result":       msg]
                    
                    // TODO: here we have to save the new KeyId in the Cache and update the cahceSecret
                    
                    completion(myJson)
                }
                
            } else if let error = response.error {
                self.delegate?.chatError(errorCode:     6200,
                                         errorMessage:  "\(CHAT_ERRORS.err6200.rawValue): \(error)",
                    errorResult:   error.localizedDescription)
                
                let myJson: JSON = ["hasError":     true,
                                    "errorCode":    6200,
                                    "errorMessage": "\(CHAT_ERRORS.err6200.rawValue) \(error)",
                                    "errorEvent":   error.localizedDescription]
                completion(myJson)
            }
        
        }

    }
    
    
    /*
     * Get Encryption Keys by KeyId:
     *
     * get the key (for Encrypt and Decrypt the Cache) from SSO by sending KeyId
     *
     *  + Access:
     *      - private
     *
     *  + Inputs:
     *      - keyAlgorithm: String?
     *      - keySize:      Int?
     *      - keyId:        String
     *
     *  + Outputs:
     *      - JSON (as completion handler)
     *
     */
    func getEncryptionKey(keyAlgorithm: String?, keySize: String?, keyId: String, completion: @escaping (JSON)->()) {
        /*
         *  -> send a .get request to the SSO server to get the secretKey with keyId
         *
         *  -> get response as String
         *  -> convert String to Data
         *  -> convert Data to JSON
         *      + JSON contains this object:
         *          - algorithm:            String  (ex: "AES")
         *          - expires_in:           Int     (ex: 315360000)
         *          - keyFormat:            String  (ex: "base64")
         *          - keyId:                String  (ex: "18294d3013f61562669359")
         *          - secretKey:            String  (ex: "8nBxSBvghRaBpwPH8ZbA1bqUa7K\/Hbr5EH5Ab1WSJJY=")
         *          + device:
         *              - agent:            String  (ex: "Mozilla\/5.0 (X11; Linux x86_64) Appl ....")
         *              - browser:          String  (ex: "Chrome")
         *              - browserVersion:   String  (ex: "59")
         *              - current:          Bool    (ex: false)
         *              - deviceType:       String  (ex: "Desktop")
         *              - id:               Int     (ex: 10368)
         *              - ip:               String  (ex: "172.16.106.42")
         *              - lastAccessTime:   Int     (ex: 1551613854000)
         *              + location:         {}
         *              - os:               String  (ex: "Linux")
         *              - uid:              String  (ex: "94af0c8f381deeb7aa28a85c473641c1-Reza")
         *          + user:
         *              - family_name:          String  (ex: "Reza")
         *              - given_name:           String  (ex: "Irani")
         *              - id:                   Int     (ex: 5098)
         *              - preferred_username:   String  (ex: "Reza")
         *          + client:
         *              + allowedGrantTypes:    []      (ex: ["authorization_code", "refresh_token", "implicit"])
         *              + allowedScopes:        []      (ex: ["phone", "legal_nationalcode", "activity", ...])
         *              + allowedRedirectUris:  []      (ex: ["*"])
         *              + allowedUserIPs:       []      (ex: ["*"])
         *              - captchaEnabled:       Bool    (ex: false)
         *              - client_id:            String  (ex: "dd5c454bb756c6de92c7cb15")
         *              - description:          String  (ex: "Keylead Root Client")
         *              - id:                   Int     (ex: 1)
         *              - loginUrl:             String  (ex: "http:\/\/podtest.fanapsoft.ir:8008\/oauth2\....")
         *              - name:                 String  (ex: "KeyleadFather")
         *              - signupEnabled:        Bool    (ex: true)
         *              - supportNumber:        String  (ex: "021-33255")
         *              - url:                  String  (ex: "http:\/\/keylead.fanapium.com")
         *              - userId:               Int     (ex: 1)
         *
         */
        // TODO: save the new keyId into the Cache
        let url = SERVICE_ADDRESSES.SSO_ADDRESS + SERVICES_PATH.SSO_GET_KEY.rawValue + "\(keyId)"
        let method: HTTPMethod = .get
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["validity":       10 * 365 * 24 * 60 * 60,  // 10 years
                                  "renew":          false,
                                  "keyAlgorithm":   keyAlgorithm ?? "aes",
                                  "keySize":        keySize ?? 256]
        
        Alamofire.request(url, method: method, parameters: params, headers: headers).responseString { (response) in
            
            if response.result.isSuccess {
                let responseStr: String = response.result.value!
                // convert String to Data
                if let dataFromMsgString = responseStr.data(using: .utf8, allowLossyConversion: false) {
                    
                    var msg: JSON
                    do {
                        // convert Data to JSON
                        msg = try JSON(data: dataFromMsgString)
                    } catch {
                        fatalError("Cannot convert Data to JSON")
                    }
                    let myJson: JSON = ["hasError":     false,
                                        "errorCode":    0,
                                        "errorMessage": "",
                                        "result":       msg]
                    
                    // TODO: here we have to save the new KeyId in the Cache and update the cahceSecret
                    
                    completion(myJson)
                }
                
            } else if let error = response.error {
                self.delegate?.chatError(errorCode:     6200,
                                         errorMessage:  "\(CHAT_ERRORS.err6200.rawValue): \(error)",
                    errorResult:   error.localizedDescription)
                
                let myJson: JSON = ["hasError":     true,
                                    "errorCode":    6200,
                                    "errorMessage": "\(CHAT_ERRORS.err6200.rawValue) \(error)",
                                    "errorEvent":   error.localizedDescription]
                completion(myJson)
            }
            
        }

    }


    
    
    /*
     *  HTTP Request:
     *      Manages all HTTP Requests
     *
     *  + Access:
     *      - private
     *
     *  + Inputs:
     *
     *
     *  + Outputs:
     *
     *
     */
    /*
    func httpRequest(from urlStr:           String,
                     withMethod:            HTTPMethod,
                     withHeaders:           HTTPHeaders?,
                     withParameters:        Parameters?,
                     dataToSend:            Any?,
                     requestUniqueId:       String?,
                     isImage:               Bool?,
                     isFile:                Bool?,
                     completion:            @escaping callbackTypeAlias,
                     progress:              callbackTypeAliasFloat?,
                     idDownloadRequest:     Bool,
                     isMapServiceRequst:    Bool,
                     downloadReturnData:    @escaping (Data?, JSON) -> ()) {
        
        let url = URL(string: urlStr)!
        
        if (idDownloadRequest) {
            
            Alamofire.request(url, method: withMethod, parameters: withParameters, headers: withHeaders).downloadProgress(closure: { (downloadProgress) in
                let myProgressFloat: Float = Float(downloadProgress.fractionCompleted)
                progress?(myProgressFloat)
            }).responseData { (myResponse) in
                if myResponse.result.isSuccess {
                    if let downloadedData = myResponse.data {
                        if let response = myResponse.response {
                            
                            var resJSON: JSON = [:]
                            
                            let headerResponse = response.allHeaderFields
                            if let contentType = headerResponse["Content-Type"] as? String {
                                if let fileType = contentType.components(separatedBy: "/").last {
                                    resJSON["type"] = JSON(fileType)
                                }
                            }
                            if let contentDisposition = headerResponse["Content-Disposition"] as? String {
                                if let theFileName = contentDisposition.components(separatedBy: "=").last?.replacingOccurrences(of: "\"", with: "") {
                                    resJSON["name"] = JSON(theFileName)
                                }
                                // return the Data:
                                downloadReturnData(downloadedData, resJSON)
                            } else {
                                // an error accured, so return the error:
                                let returnJSON: JSON = ["hasError": true, "errorCode": 999]
                                downloadReturnData(nil, returnJSON)
                            }
                            
                        }
                    }
                } else {
                    print("Failed!")
                }
            }
            
        } else {
            
            if (withMethod == .get) {
                
                if isMapServiceRequst {
                    Alamofire.request(url, method: withMethod, parameters: withParameters, headers: withHeaders).responseJSON { (myResponse) in
                        if myResponse.result.isSuccess {
                            if let jsonValue = myResponse.result.value {
                                let jsonResponse: JSON = JSON(jsonValue)
                                completion(jsonResponse)
                            }
                        } else {
                            log.error("Response of GerRequest is Failed)", context: "Chat")
                        }
                    }
                    
                } else {
                    Alamofire.request(url, method: withMethod, parameters: withParameters, headers: withHeaders).responseString { (response) in
                        if response.result.isSuccess {
                            let stringToReturn: String = response.result.value!
                            completion(stringToReturn)
                        } else {
                            log.error("Response of GerRequest is Failed)", context: "Chat")
                        }
                    }
                }
                
            } else if (withMethod == .post) {
                
                if dataToSend == nil {
                    Alamofire.request(url, method: withMethod, parameters: withParameters, headers: withHeaders).responseJSON { (myResponse) in
                        if myResponse.result.isSuccess {
                            if let jsonValue = myResponse.result.value {
                                let jsonResponse: JSON = JSON(jsonValue)
                                completion(jsonResponse)
                            }
                        } else {
                            if let error = myResponse.error {
                                let myJson: JSON = ["hasError": true,
                                                    "errorCode": 6200,
                                                    "errorMessage": "\(CHAT_ERRORS.err6200.rawValue) \(error)",
                                    "errorEvent": error.localizedDescription]
                                completion(myJson)
                            }
                        }
                    }
                    
                } else {
                    
                    Alamofire.upload(multipartFormData: { (multipartFormData) in
                        
                        if let hasImage = isImage {
                            if (hasImage == true) {
                                multipartFormData.append(dataToSend as! Data, withName: "image")
                            }
                        }
                        
                        if let hasFile = isFile {
                            if (hasFile == true) {
                                multipartFormData.append(dataToSend as! Data, withName: "file")
                            }
                        }
                        
                        
                        if let header = withHeaders {
                            for (key, value) in header {
                                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key as String)
                            }
                        }
                        if let parameters = withParameters {
                            for (key, value) in parameters {
                                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as String)
                            }
                        }
                    }, to: urlStr) { (myResult) in
                        switch myResult {
                        case .success(let upload, _, _):
                            self.uploadRequest.append((upload: upload, uniqueId: requestUniqueId!))
                            upload.responseJSON(completionHandler: { (response) in
                                if let jsonValue = response.result.value {
                                    let jsonResponse: JSON = JSON(jsonValue)
                                    completion(jsonResponse)
                                }
                            })
                            upload.uploadProgress(closure: { (myProgress) in
                                let myProgressFloat: Float = Float(myProgress.fractionCompleted)
                                progress?(myProgressFloat)
                            })
                            upload.responseJSON { response in
                                debugPrint(response)
                                for (index, item) in self.uploadRequest.enumerated() {
                                    if item.uniqueId == requestUniqueId {
                                        self.uploadRequest.remove(at: index)
                                    }
                                }
                                
                            }
                        case .failure(let error):
                            completion(error)
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    */
    
    
    /*
     *
     *
     */
    func chatSendQueueHandler() {
        
    }
    
    
    func sendMessageWithCallback(asyncMessageVO:    SendAsyncMessageVO,
                                 callback:          CallbackProtocol?,
                                 callbacks:         [CallbackProtocol]?,
                                 sentCallback:      CallbackProtocolWith3Calls?,
                                 deliverCallback:   CallbackProtocolWith3Calls?,
                                 seenCallback:      CallbackProtocolWith3Calls?,
                                 uniuqueIdCallback: callbackTypeAliasString?) {
        
        let chatMessageVO = SendChatMessageVO(content: asyncMessageVO.content.convertToJSON())
        
        let uniqueId = chatMessageVO.uniqueId ?? ""
        if (uniqueId != "") {
            uniuqueIdCallback?(uniqueId)
        }
        
        if (callback != nil) {
            if (asyncMessageVO.content.convertToJSON()["chatMessageVOType"].intValue == 41) {
                Chat.spamMap[uniqueId] = [callback, callback, callback] as? [CallbackProtocol]
            } else {
                Chat.map[uniqueId] = callback
            }
        }
        
        if let myCallbacks = callbacks {
            for (index, item) in myCallbacks.enumerated() {
                let uIdJSON = chatMessageVO.content?.convertToJSON()
                if let uIds = uIdJSON?["uniqueIds"].arrayObject as? [String] {
                    let uId = uIds[index]
                    Chat.map[uId] = item
                }
            }
        }
        if (sentCallback != nil) {
            Chat.mapOnSent[uniqueId] = sentCallback
        }
        if (deliverCallback != nil) {
            let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uniqueId: deliverCallback!]
            if Chat.mapOnDeliver["\(chatMessageVO.subjectId ?? 0)"] != nil {
                Chat.mapOnDeliver["\(chatMessageVO.subjectId ?? 0)"]!.append(uniqueIdDic)
            } else {
                Chat.mapOnDeliver["\(chatMessageVO.subjectId ?? 0)"] = [uniqueIdDic]
            }
        }
        if (seenCallback != nil) {
            let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uniqueId: deliverCallback!]
            if Chat.mapOnSeen["\(chatMessageVO.subjectId ?? 0)"] != nil {
                Chat.mapOnSeen["\(chatMessageVO.subjectId ?? 0)"]!.append(uniqueIdDic)
            } else {
                Chat.mapOnSeen["\(chatMessageVO.subjectId ?? 0)"] = [uniqueIdDic]
            }
        }
        
        log.verbose("map json: \n \(Chat.map)", context: "Chat")
        log.verbose("map onSent json: \n \(Chat.mapOnSent)", context: "Chat")
        log.verbose("map onDeliver json: \n \(Chat.mapOnDeliver)", context: "Chat")
        log.verbose("map onSeen json: \n \(Chat.mapOnSeen)", context: "Chat")
        
        let contentToSend = asyncMessageVO.convertModelToString()
        
        log.verbose("AsyncMessageContent of type JSON (to send to socket): \n \(contentToSend)", context: "Chat")
        
        asyncClient?.pushSendData(type: asyncMessageVO.pushMsgType ?? 3, content: contentToSend)
        runSendMessageTimer()
        
    }
    
    /*
     *
     *
     *
     
    func sendMessageWithCallback(params:            JSON,
                                 callback:          CallbackProtocol?,
                                 callbacks:         [CallbackProtocol]?,
                                 sentCallback:      CallbackProtocolWith3Calls?,
                                 deliverCallback:   CallbackProtocolWith3Calls?,
                                 seenCallback:      CallbackProtocolWith3Calls?,
                                 uniuqueIdCallback: callbackTypeAliasString?) {
        log.verbose("params (to send): \n \(params)", context: "Chat")
        
        /*
         * + ChatMessage        {object}
         *    - token           {string}
         *    - tokenIssuer     {string}
         *    - type            {int}
         *    - subjectId       {long}
         *    - uniqueId        {string}
         *    - content         {string}
         *    - time            {long}
         *    - medadata        {string}
         *    - systemMedadata  {string}
         *    - repliedTo       {long}
         */
        //        var returnData: JSON = ["uniqueId": "", "threadId": 0, "participant": userInfo as Any, "content": params["content"]]
        
        var messageVO: JSON = ["type": params["chatMessageVOType"].intValue,
                               "token": token,
                               "tokenIssuer": 1]
        var threadId: Int = 0
        if let theSubjectId = params["subjectId"].int {
            threadId = theSubjectId
//            messageVO["threadId"] = JSON(theSubjectId)
            messageVO["subjectId"] = JSON(theSubjectId)
        }
        
        if let repliedTo = params["repliedTo"].int {
            messageVO["repliedTo"] = JSON(repliedTo)
        }
        
        if let content = params["content"].string {
            messageVO["content"] = JSON(content)
        } else {
            let content = "\(params["content"])"
            messageVO["content"] = JSON(content)
        }
        
        if let metaData = params["metaData"].string {
            messageVO["metaData"] = JSON(metaData)
        }
        
        if let systemMetadata = params["systemMetadata"].string {
            messageVO["systemMetadata"] = JSON(systemMetadata)
        }
        
        if let typeCode = params["typeCode"].string {
            messageVO["typeCode"] = JSON(typeCode)
        } else {
            //            messageVO["typeCode"] = JSON(generalTypeCode)
        }
        
        var uniqueId: String = ""
        if let uID = params["uniqueId"].string {
            messageVO["uniqueId"] = JSON(uID)
            //            returnData["uniqueId"] = JSON(uID)
            uniqueId = uID
        } else if (params["chatMessageVOType"].intValue == chatMessageVOTypes.DELETE_MESSAGE.rawValue) {
            if let x = params["content"]["ids"].arrayObject {
                if x.count <= 1 {
                    let uID = generateUUID()
                    messageVO["uniqueId"] = JSON(uID)
                    uniqueId = uID
                }
            } else {
                let uID = generateUUID()
                messageVO["uniqueId"] = JSON(uID)
                uniqueId = uID
            }
        } else if (params["chatMessageVOType"].intValue != chatMessageVOTypes.PING.rawValue) {
            let uID = generateUUID()
            messageVO["uniqueId"] = JSON(uID)
            //            returnData["uniqueId"] = JSON(uID)
            uniqueId = uID
        }
        if (uniqueId != "") {
            uniuqueIdCallback?(uniqueId)
        }
        
        
        log.verbose("MessageVO params (to send): \n \(messageVO)", context: "Chat")
        
        if (callback != nil) {
            Chat.map[uniqueId] = callback
        }
        
        if let myCallbacks = callbacks {
            for (index, item) in myCallbacks.enumerated() {
                if let uIds = params["content"]["uniqueIds"].arrayObject as? [String] {
                    let uId = uIds[index]
                    Chat.map[uId] = item
                }
            }
        }
        
        if (sentCallback != nil) {
            Chat.mapOnSent[uniqueId] = sentCallback
        }
        
        if (deliverCallback != nil) {
            let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uniqueId: deliverCallback!]
            if Chat.mapOnDeliver["\(threadId)"] != nil {
                Chat.mapOnDeliver["\(threadId)"]!.append(uniqueIdDic)
            } else {
                Chat.mapOnDeliver["\(threadId)"] = [uniqueIdDic]
            }
        }
        
        if (seenCallback != nil) {
            let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uniqueId: deliverCallback!]
            if Chat.mapOnSeen["\(threadId)"] != nil {
                Chat.mapOnSeen["\(threadId)"]!.append(uniqueIdDic)
            } else {
                Chat.mapOnSeen["\(threadId)"] = [uniqueIdDic]
            }
        }
        
        log.verbose("map json: \n \(Chat.map)", context: "Chat")
        log.verbose("map onSent json: \n \(Chat.mapOnSent)", context: "Chat")
        log.verbose("map onDeliver json: \n \(Chat.mapOnDeliver)", context: "Chat")
        log.verbose("map onSeen json: \n \(Chat.mapOnSeen)", context: "Chat")
        
        
        var type: Int = 3
        if let theType = params["pushMsgType"].int {
            type = theType
        }
        var content: JSON = [:]
        let messageVOStr = "\(messageVO)"
        let str = String(messageVOStr.filter { !"\n\t\r".contains($0) })
        content["content"] = JSON("\(str)")
        content["peerName"] = JSON(serverName)
        content["priority"] = JSON(msgPriority)
        content["ttl"] = JSON(msgTTL)
        let contentStr = "\(content)"
        
        let str2 = String(contentStr.filter { !"\n\t\r".contains($0) })
        log.verbose("AsyncMessageContent of type JSON (to send to socket): \n \(str2)", context: "Chat")
        
        asyncClient?.pushSendData(type: type, content: str2)
        runSendMessageTimer()
    }
    
    */
    
    
    /* this method is deprecated because af using a class inside Async
    /*
     it's all about this 3 characters: 'space' , '\n', '\t'
     this function will put some freak characters instead of these 3 characters (inside the Message text content)
     because later on, the Async will eliminate from all these kind of characters to reduce size of the message that goes through socket,
     on there, we will replace them with the original one;
     so now we don't miss any of these 3 characters on the Test Message, but also can eliminate all extra characters...
     */
    func makeCustomTextToSend(textMessage: String) -> String {
        var returnStr = ""
        for c in textMessage {
            if (c == " ") {
                returnStr.append("Ⓢ")
            } else if (c == "\n") {
                returnStr.append("Ⓝ")
            } else if (c == "\t") {
                returnStr.append("Ⓣ")
            } else {
                returnStr.append(c)
            }
        }
        return returnStr
    }
    */
    
    
    /*
     * Run timer
     *
     * This Function will run the timer
     * if there is "chatPingMessageInterval" seconds that threre was no message sends through chat
     * it will send a ping message to keep user connected to chat
     *
     * + Access:    private
     * + Inputs:    nothing
     * + Outputs:   nothing
     *
     */
    func runSendMessageTimer() {
        /*
         * first of all, it will suspend the timer
         * then on the background thread it will run a timer
         * if the "chatState" = true (means chat is still connected)
         * and there are "chatPingMessageInterval" seconds passed from last message that sends to chat
         * it will send a ping message on the main thread
         *
         */
        self.lastSentMessageTimeoutId?.suspend()
        DispatchQueue.global().async {
            self.lastSentMessageTime = Date()
            self.lastSentMessageTimeoutId = RepeatingTimer(timeInterval: TimeInterval(self.chatPingMessageInterval))
            self.lastSentMessageTimeoutId?.eventHandler = {
                if let lastSendMessageTimeBanged = self.lastSentMessageTime {
                    let elapsed = Int(Date().timeIntervalSince(lastSendMessageTimeBanged))
                    if (elapsed >= self.chatPingMessageInterval) && (self.chatState == true) {
                        DispatchQueue.main.async {
                            self.ping()
                        }
                        self.lastSentMessageTimeoutId?.suspend()
                    }
                }
            }
            self.lastSentMessageTimeoutId?.resume()
        }
    }
    
    
    /*
     * Ping
     *
     * This Function sends ping message to keep the user connected to the chat server
     *
     * + Access:    private
     * + Inputs:    _
     * + Outputs:   _
     *
     */
    func ping() {
        /*
         *
         *  -> if chat is connected and we also have the peerId
         *  -> then send a message of type PING
         *      (Ping messages should be sent ASAP,
         *       because we don't want to wait for send queue,
         *       so we send them right through the async from here)
         *  -> then reset the value of the timer ("lastSentMessageTimeoutId")
         *
         */
        if (chatState == true && peerId != nil && peerId != 0) {
            
            log.verbose("Try to send Ping", context: "Chat")
            
//            let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.PING.rawValue, "pushMsgType": 5]
            let chatMessage = SendChatMessageVO(chatMessageVOType: chatMessageVOTypes.PING.rawValue,
                                                content:            nil,
                                                metaData:           nil,
                                                repliedTo:          nil,
                                                systemMetadata:     nil,
                                                subjectId:          nil,
                                                token:              token,
                                                tokenIssuer:        nil,
                                                typeCode:           nil,
                                                uniqueId:           nil,
                                                isCreateThreadAndSendMessage: nil)
            
            let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                                  msgTTL:       msgTTL,
                                                  peerName:     serverName,
                                                  priority:     msgPriority,
                                                  pushMsgType:  5)
            
            sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                    callback:           nil,
                                    callbacks:          nil,
                                    sentCallback:       nil,
                                    deliverCallback:    nil,
                                    seenCallback:       nil,
                                    uniuqueIdCallback:  nil)
        } else if (lastSentMessageTimeoutId != nil) {
            lastSentMessageTimeoutId?.suspend()
        }
    }
    
    
    /*
     * this method is not usable anymore,
     * bacause I moved it's functionalities to the "receivedMessageHandler" method
     *
     func pushMessageHandler(params: JSON) {
     
     log.verbose("receive message: \n \(params)", context: "Chat")
     
     /*
     * + Message Received From Async      {object}
     *    - id                            {long}
     *    - senderMessageId               {long}
     *    - senderName                    {string}
     *    - senderId                      {long}
     *    - type                          {int}
     *    - content                       {string}
     */
     
     lastReceivedMessageTime = Date()
     
     let content = params["content"].stringValue
     
     // convert my parameters data from string to JSON
     let msgJSON: JSON = content.convertToJSON()
     receivedMessageHandler(params: msgJSON)
     }
     */
    
    
    /*
     * Received Message Handler:
     *
     * Handle recieve message from Async
     *
     *  + Message Received From Async    JSON
     *      - id:               Int
     *      - type:             Int
     *      - senderMessageId:  Int
     *      - senderName:       String
     *      - senderId:         Int
     *      - uniqueId:         String
     *      + content:              String(JSON)
     *          - contentCount:          Int
     *          - type:                  Int
     *          - uniqueId:              String
     *          - threadId:              Int
     *          - content:               String
     *
     */
    func receivedMessageHandler(withContent message: ChatMessage) {
//        log.debug("content of received message: \n \(message.returnToJSON())", context: "Chat")
        
        lastReceivedMessageTime = Date()
        
//        let messageStringContent = withContent["content"].stringValue
//        let chatContent: JSON = messageStringContent.convertToJSON()
//
//        let type        = chatContent["type"].intValue
//        let uniqueId    = chatContent["uniqueId"].stringValue
//        var threadId = 0
//        if let theThreadId = chatContent["subjectId"].int {
//            threadId = theThreadId
//        }
//        var contentCount = 0
//        if let theContentCount = chatContent["contentCount"].int {
//            contentCount = theContentCount
//        }
//        var messageContent: JSON = [:]
//        var messageContentAsString = ""
//        if let msgCont = chatContent["content"].string {
//            messageContentAsString = msgCont
//            messageContent = msgCont.convertToJSON()
//        }
        
        
//        let type                    = withContent.type
//        let uniqueId                = withContent.uniqueId
//        let threadId                = withContent.subjectId ?? 0
//        let contentCount            = withContent.contentCount ?? 0
        let messageContentAsString      = message.content
        var messageContentAsJSON: JSON  = message.content?.convertToJSON() ?? [:]
        
        switch message.type {
            
        // a message of type 1 (CREATE_THREAD) comes from Server.
        case chatMessageVOTypes.CREATE_THREAD.rawValue:
            responseOfCreateThread(withMessage: message)
            break
            
            // a message of type 2 (MESSAGE) comes from Server.
        // this means that a message comes.
        case chatMessageVOTypes.MESSAGE.rawValue:
            log.verbose("Message of type 'MESSAGE' recieved", context: "Chat")
//            chatMessageHandler(threadId: threadId, messageContent: messageContent)
            chatMessageHandler(threadId: message.subjectId ?? 0, messageContent: messageContentAsJSON)
            break
            
            // a message of type 3 (SENT) comes from Server.
        // it means that the message is send.
        case chatMessageVOTypes.SENT.rawValue:
            responseOfOnSendMessage(withMessage: message)
            break
            
            // a message of type 4 (DELIVERY) comes from Server.
        // it means that the message is delivered.
        case chatMessageVOTypes.DELIVERY.rawValue:
            responseOfOnDeliveredMessage(withMessage: message)
            break
            
            // a message of type 5 (SEEN) comes from Server.
        // it means that the message is seen.
        case chatMessageVOTypes.SEEN.rawValue:
            responseOfOnSeenMessage(withMessage: message)
            break
            
            // a message of type 6 (PING) comes from Server.
        // it means that a ping message comes.
        case chatMessageVOTypes.PING.rawValue:
            log.verbose("Message of type 'PING' recieved", context: "Chat")
            break
            
            // a message of type 7 (BLOCK) comes from Server.
        // it means that a user has blocked.
        case chatMessageVOTypes.BLOCK.rawValue:
            responseOfBlockContact(withMessage: message)
            break
            
            // a message of type 8 (UNBLOCK) comes from Server.
        // it means that a user has unblocked.
        case chatMessageVOTypes.UNBLOCK.rawValue:
            responseOfUnblockContact(withMessage: message)
            break
            
            // a message of type 9 (LEAVE_THREAD) comes from Server.
        // it means that a you has leaved the thread.
        case chatMessageVOTypes.LEAVE_THREAD.rawValue:
            responseOfLeaveThread(withMessage: message)
            break
            
        // a message of type 10 (RENAME) comes from Server.
        case chatMessageVOTypes.RENAME.rawValue:
            //
            break
            
            // a message of type 11 (ADD_PARTICIPANT) comes from Server.
        // it means some participants added to the thread.
        case chatMessageVOTypes.ADD_PARTICIPANT.rawValue:
            responseOfAddParticipant(withMessage: message)
            break
            
        // a message of type 12 (GET_STATUS) comes from Server.
        case chatMessageVOTypes.GET_STATUS.rawValue:
            //
            break
            
        // a message of type 13 (GET_CONTACTS) comes from Server.
        case chatMessageVOTypes.GET_CONTACTS.rawValue:
            responseOfGetContacts(withMessage: message)
            break
            
        // a message of type 14 (GET_THREADS) comes from Server.
        case chatMessageVOTypes.GET_THREADS.rawValue:
            responseOfGetThreads(withMessage: message)
            break
            
        // a message of type 15 (GET_HISTORY) comes from Server.
        case chatMessageVOTypes.GET_HISTORY.rawValue:
            responseOfGetHistory(withMessage: message)
            break
            
        // a message of type 16 (CHANGE_TYPE) comes from Server.
        case chatMessageVOTypes.CHANGE_TYPE.rawValue:
            break
            
        // a message of type 17 (REMOVED_FROM_THREAD) comes from Server.
        case chatMessageVOTypes.REMOVED_FROM_THREAD.rawValue:
            let result: JSON = ["thread": message.subjectId ?? 0]
//            delegate?.threadEvents(type: ThreadEventTypes.removedFrom, result: result)
            break
            
        // a message of type 18 (REMOVE_PARTICIPANT) comes from Server.
        case chatMessageVOTypes.REMOVE_PARTICIPANT.rawValue:
            responseOfRemoveParticipant(withMessage: message)
            break
            
        // a message of type 19 (MUTE_THREAD) comes from Server.
        case chatMessageVOTypes.MUTE_THREAD.rawValue:
            responseOfMuteThread(withMessage: message)
            break
            
        // a message of type 20 (UNMUTE_THREAD) comes from Server.
        case chatMessageVOTypes.UNMUTE_THREAD.rawValue:
            responseOfUnmuteThread(withMessage: message)
            break
            
        // a message of type 21 (UPDATE_THREAD_INFO) comes from Server.
        case chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue:
            responseOfUpdateThreadInfo(withMessage: message)
            break
            
        // a message of type 22 (FORWARD_MESSAGE) comes from Server.
        case chatMessageVOTypes.FORWARD_MESSAGE.rawValue:
            log.verbose("Message of type 'FORWARD_MESSAGE' recieved", context: "Chat")
            chatMessageHandler(threadId: message.subjectId ?? 0, messageContent: messageContentAsJSON)
            break
            
        // a message of type 23 (USER_INFO) comes from Server.
        case chatMessageVOTypes.USER_INFO.rawValue:
            responseOfUserInfo(withMessage: message)
            break
            
        // a message of type 24 (USER_STATUS) comes from Server.
        case chatMessageVOTypes.USER_STATUS.rawValue:
            break
            
        // a message of type 25 (GET_BLOCKED) comes from Server.
        case chatMessageVOTypes.GET_BLOCKED.rawValue:
            responseOfGetBlockContact(withMessage: message)
            break
            
        // a message of type 26 (RELATION_INFO) comes from Server.
        case chatMessageVOTypes.RELATION_INFO.rawValue:
            break
            
        // a message of type 27 (THREAD_PARTICIPANTS) comes from Server.
        case chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue:
            responseOfThreadParticipants(withMessage: message)
            break
            
        // a message of type 28 (EDIT_MESSAGE) comes from Server.
        case chatMessageVOTypes.EDIT_MESSAGE.rawValue:
            responseOfEditMessage(withMessage: message)
            break
            
        // a message of type 29 (DELETE_MESSAGE) comes from Server.
        case chatMessageVOTypes.DELETE_MESSAGE.rawValue:
            responseOfDeleteMessage(withMessage: message)
            break
            
        // a message of type 30 (THREAD_INFO_UPDATED) comes from Server.
        case chatMessageVOTypes.THREAD_INFO_UPDATED.rawValue:
            log.verbose("Message of type 'THREAD_INFO_UPDATED' recieved", context: "Chat")
            let conversation: Conversation = Conversation(messageContent: messageContentAsJSON)
            let result: JSON = ["thread": conversation]
//            delegate?.threadEvents(type: ThreadEventTypes.infoUpdated, result: result)
            break
            
        // a message of type 31 (LAST_SEEN_UPDATED) comes from Server.
        case chatMessageVOTypes.LAST_SEEN_UPDATED.rawValue:
            log.verbose("Message of type 'LAST_SEEN_UPDATED' recieved", context: "Chat")
//            delegate?.threadEvents(type: ThreadEventTypes.lastSeenUpdate, result: messageContent)
            // this functionality has beed deprecated
            /*
             let paramsToSend: JSON = ["threadIds": messageContent["conversationId"].intValue]
             getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
             let myResponseModel: GetThreadsModel = myResponse as! GetThreadsModel
             let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
             let threads = myResponseJSON["result"]["threads"].arrayValue
             
             let result: JSON = ["thread": threads,
             "messageId": messageContent["messageId"].intValue,
             "senderId": messageContent["participantId"].intValue]
             self.delegate?.threadEvents(type: "THREAD_UNREAD_COUNT_UPDATED", result: result)
             
             let result2: JSON = ["thread": threads]
             self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: result2)
             }
             */
            
            break
            
        // a message of type 32 (GET_MESSAGE_DELEVERY_PARTICIPANTS) comes from Server.
        case chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue:
            responseOfMessageDeliveryList(withMessage: message)
            break
            
        // a message of type 33 (GET_MESSAGE_SEEN_PARTICIPANTS) comes from Server.
        case chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue:
            responseOfMessageSeenList(withMessage: message)
            break
            
        // a message of type 40 (BOT_MESSAGE) comes from Server.
        case chatMessageVOTypes.BOT_MESSAGE.rawValue:
            log.verbose("Message of type 'BOT_MESSAGE' recieved", context: "Chat")
            //            let result: JSON = ["bot": messageContent]
            //            self.delegate?.botEvents(type: "BOT_MESSAGE", result: result)
            break
            
        // a message of type 41 (SPAM_PV_THREAD) comes from Server.
        case chatMessageVOTypes.SPAM_PV_THREAD.rawValue:
//            responseOfSpamPvThread(withMessage: message)
            break
            
        // a message of type 42 (SET_RULE_TO_USER) comes from Server.
        case chatMessageVOTypes.SET_RULE_TO_USER.rawValue:
            responseOfSetRoleToUser(withMessage: message)
            break
            
        // a message of type 44 (CLEAR_HISTORY) comes from Server.
        case chatMessageVOTypes.CLEAR_HISTORY.rawValue:
            responseOfClearHistory(withMessage: message)
            break
            
        // a message of type 45 (SIGNAL_MESSAGE) comes from Server
        case chatMessageVOTypes.SYSTEM_MESSAGE.rawValue:
            log.verbose("Message of type 'SIGNAL_MESSAGE' revieved", context: "Chat")
//            delegate?.threadEvents(type: ThreadEventTypes.isTyping, result: "\(messageContentAsString)")
            return
            
        // a message of type 100 (LOGOUT) comes from Server.
        case chatMessageVOTypes.LOGOUT.rawValue:
            break
            
        // a message of type 999 (ERROR) comes from Server.
        case chatMessageVOTypes.ERROR.rawValue:
            log.verbose("Message of type 'ERROR' recieved", context: "Chat")
            if Chat.map[message.uniqueId] != nil {
//                let message: String = messageContentAsJSON["message"].stringValue
//                let code: Int = messageContentAsJSON["code"].intValue
                
                let returnData = CreateReturnData(hasError:       true,
                                                  errorMessage:   message.message,
                                                  errorCode:      message.code,
                                                  result:         messageContentAsJSON,
                                                  resultAsArray: nil,
                                                  resultAsString: nil,
                                                  contentCount:   0,
                                                  subjectId:      message.subjectId)
//                    .returnJSON()
                
                let callback: CallbackProtocol = Chat.map[message.uniqueId]!
                callback.onResultCallback(uID:      message.uniqueId,
                                          response: returnData,
                                          success:  { (successJSON) in
                    self.spamPvThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: message.uniqueId)
                
                if (messageContentAsJSON["code"].intValue == 21) {
                    chatState = false
                    asyncClient?.asyncLogOut()
                    //                    clearCache()
                }
                delegate?.chatError(errorCode: message.code ?? 0, errorMessage: message.message ?? "", errorResult: messageContentAsJSON)
            }
            break
            
        default:
            //            print("This type of message is not defined yet!!!")
            log.warning("This type of message is not defined yet!!!\n incomes = \(message.returnToJSON())", context: "Chat")
            break
        }
    }
    
    
    
    
    func chatMessageHandler(threadId: Int, messageContent: JSON) {
        let message = Message(threadId: threadId, pushMessageVO: messageContent)
        
        if let messageOwner = message.participant?.id {
            if messageOwner != userInfo?.id {
                let deliveryModel = DeliverSeenRequestModel(messageId: message.id, ownerId: messageOwner, typeCode: nil)
                deliver(deliverInput: deliveryModel)
            }
        }
        
        if enableCache {
            // save data comes from server to the Cache
            let theMessage = Message(threadId: threadId, pushMessageVO: messageContent)
            Chat.cacheDB.saveMessageObjects(messages: [theMessage], getHistoryParams: nil)
        }
        
        delegate?.messageEvents(type: MessageEventTypes.MESSAGE_NEW, result: message)
    }
    
    
    
    
    /*
     * i created a class for this method to do the same exact functionality
     * so this method is deprecated
     *
     func createReturnData(hasError: Bool, errorMessage: String?, errorCode: Int?, result: JSON?, resultAsString: String?, contentCount: Int?, subjectId: Int?) -> JSON {
     
     
     let hasErr = hasError
     
     let errMsg: String
     var errCode: Int
     var contCount: Int
     if let theErrMsg = errorMessage {
     errMsg = theErrMsg
     } else {
     errMsg = ""
     }
     if let errC = errorCode {
     errCode = errC
     } else {
     errCode = 0
     }
     if let theCount = contentCount {
     contCount = theCount
     } else {
     contCount = 0
     }
     
     var obj: JSON = ["hasError": hasErr,
     "errorMessage": errMsg,
     "errorCode": errCode,
     "result": NSNull(),
     "contentCount": contCount,
     "subjectId": subjectId ?? NSNull()]
     
     if let myResult = result {
     obj["result"] = myResult
     } else if let myResult = resultAsString {
     obj["result"] = JSON(myResult)
     }
     
     return obj
     }
     *
     */
    
    
    
    
    
    
    
//    func x(chatContent: JSON, messageContent: JSON, contentCount: Int, uniqueId: String) {
//
//        if Chat.map[uniqueId] != nil {
//            let returnData = CreateReturnData(hasError:         false,
//                                              errorMessage:     "",
//                                              errorCode:        0,
//                                              result:           messageContent,
//                                              resultAsArray:    nil,
//                                              resultAsString:   nil,
//                                              contentCount:     contentCount,
//                                              subjectId:        chatContent["subjectId"].int)
////                .returnJSON()
//
//            let callback: CallbackProtocol = Chat.map[uniqueId]!
//            callback.onResultCallback(uID:      uniqueId,
//                                      response: returnData,
//                                      success: { (successJSON) in
//                self.blockCallbackToUser?(successJSON)
//            }) { _ in }
//            Chat.map.removeValue(forKey: uniqueId)
//        }
//    }
    
    
}



