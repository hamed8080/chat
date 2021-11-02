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
        guard let config = chat.config else{return}
        let headers: HTTPHeaders = ["Authorization": "Bearer \(config.token)"]
        let url = config.ssoHost + SERVICES_PATH.SSO_DEVICES.rawValue
        RequestManager.request(ofType:DevicesResposne.self, bodyData: nil , url: url, method: .get, headers: headers) { devicesResponse , error in
            if let error = error {
                chat.delegate?.chatError(error: error)
            }
            if let device = devicesResponse?.devices?.first(where: {$0.current == true}){
                chat.config?.deviceId = device.uid
                chat.asyncManager.createAsync()
            }
        }
    }
}
