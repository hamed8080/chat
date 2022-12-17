//
// Chat+DeviceId.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

// Request
extension Chat {
    func requestDeviceId() {
        let url = "\(config.ssoHost)\(Routes.ssoDevices.rawValue)"
        let headers = ["Authorization": "Bearer \(config.token)"]
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            let result: ChatResponse<DevicesResposne>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                if let device = result?.result?.devices?.first(where: { $0.current == true }) {
                    self?.config.asyncConfig.deviceId = device.uid ?? UUID().uuidString
                    self?.asyncManager.createAsync()
                }
            }
        }
        .resume()
    }
}
