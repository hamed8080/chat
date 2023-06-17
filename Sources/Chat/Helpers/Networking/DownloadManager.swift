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

    func download(_ params: DownloadManagerParameters, progress: DownloadProgressType? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        var request = URLRequest(url: params.url)
        params.headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        if let parameters = params.params, parameters.count > 0, params.method == .get {
            var urlComp = URLComponents(string: params.url.absoluteString)!
            urlComp.queryItems = []
            parameters.forEach { key, value in
                urlComp.queryItems?.append(URLQueryItem(name: key, value: "\(value)"))
            }
            request.url = urlComp.url
        }
        request.method = params.method
        let delegate = ProgressImplementation(uniqueId: params.uniqueId, downloadProgress: progress) { data, response, error in
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
