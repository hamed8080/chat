//
// DownloadManager.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class DownloadManager {
    private let callbackManager: CallbacksManager
    init(callbackManager: CallbacksManager) {
        self.callbackManager = callbackManager
    }

    func download(url: String,
                  method: HTTPMethod = .get,
                  uniqueId: String,
                  headers: [String: String]?,
                  parameters: [String: Any]?,
                  downloadProgress: DownloadProgressType?,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        guard var urlObj = URL(string: url) else { return }
        var request = URLRequest(url: urlObj)
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        if let parameters = parameters, parameters.count > 0, method == .get {
            var urlComp = URLComponents(string: url)!
            urlComp.queryItems = []
            parameters.forEach { key, value in
                urlComp.queryItems?.append(URLQueryItem(name: key, value: "\(value)"))
            }
            urlObj = urlComp.url ?? urlObj
        }
        request.url = urlObj
        request.httpMethod = method.rawValue
        let delegate = ProgressImplementation(uniqueId: uniqueId, downloadProgress: downloadProgress) { [weak self] data, response, error in
            DispatchQueue.main.async {
                completion(data, response, error)
                self?.callbackManager.removeDownloadTask(uniqueId: uniqueId)
            }
        }
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)
        let downloadTask = session.dataTask(with: request)
        downloadTask.resume()
        callbackManager.addDownloadTask(task: downloadTask, uniqueId: uniqueId)
    }
}
