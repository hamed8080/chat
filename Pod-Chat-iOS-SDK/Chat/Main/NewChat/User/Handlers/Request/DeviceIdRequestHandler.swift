//
//  DeviceIdRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/14/21.
//

import Foundation
import Alamofire

public class DeviceIdRequestHandler {
    
    private init(){}
    
    public class func getDeviceIdAndCreateAsync(chat:Chat){
        guard let createChatModel = chat.createChatModel else{return}
        let headers: HTTPHeaders = ["Authorization": "Bearer \(createChatModel.token)"]
        let url = createChatModel.ssoHost + SERVICES_PATH.SSO_DEVICES.rawValue
        RequestManager.request(ofType:DevicesResposne.self, bodyData: nil , url: url, method: .get, headers: headers) { devicesResponse , error in
            if let error = error {
                chat.delegate?.chatError(errorCode: error.errorCode ?? 0, errorMessage: error.message ?? "", errorResult: nil)
            }
            if let device = devicesResponse?.devices?.first(where: {$0.current == true}){
                chat.createChatModel?.deviceId = device.uid
                chat.CreateAsync()
            }
        }
    }
}
