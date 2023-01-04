//
// DeviceIdRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public class DeviceIdRequestHandler {
    private init() {}

    public class func getDeviceIdAndCreateAsync(chat: Chat) {
        guard let config = chat.config else { return }
        let headers = ["Authorization": "Bearer \(config.token)"]
        let url = config.ssoHost + Routes.ssoDevices.rawValue
        RequestManager.request(ofType: DevicesResposne.self, bodyData: nil, url: url, method: .get, headers: headers) { devicesResponse, error in
            if let error = error {
                chat.delegate?.chatError(error: error)
            }
            if let device = devicesResponse?.devices?.first(where: { $0.current == true }) {
                chat.config?.asyncConfig.updateDeviceId(device.uid ?? UUID().uuidString)
                chat.asyncManager.createAsync()
            }
        }
    }
}
