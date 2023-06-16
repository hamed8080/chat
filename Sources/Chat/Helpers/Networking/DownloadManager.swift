//
// DownloadManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import Foundation

final class DownloadManager {
    private let chat: ChatInternalProtocol
    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func download(url: String,
                  method: HTTPMethod = .get,
                  uniqueId: String,
                  headers: [String: String]? = nil,
                  parameters: [String: Any]? = nil,
                  downloadProgress: DownloadProgressType? = nil,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask?
    {
        guard var urlObj = URL(string: url) else { return nil }
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
        request.method = method
        let delegate = ProgressImplementation(uniqueId: uniqueId, downloadProgress: downloadProgress) { data, response, error in
            DispatchQueue.main.async {
                completion(data, response, error)
            }
        }
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)
        let downloadTask = session.dataTask(with: request)
        downloadTask.resume()
        return downloadTask
    }
}
