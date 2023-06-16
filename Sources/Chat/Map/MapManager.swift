//
// MapManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

final class MapManager: InternalMapProtocol {
    let chat: ChatInternalProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func image(_ request: MapStaticImageRequest) {
        image(request, nil)
    }

    func image(_ request: MapStaticImageRequest, _ completion: ((ChatResponse<Data>) -> Void)? = nil) {
        let request = MapStaticImageRequest(request: request, key: chat.config.mapApiKey)
        let url = "\(chat.config.mapServer)\(Routes.mapStaticImage.rawValue)"
        _ = DownloadManager(chat: chat)
            .download(url: url, uniqueId: request.chatUniqueId, parameters: try? request.asDictionary())
            { [weak self] data, response, error in
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let error = error != nil ? ChatError(message: "\(ChatErrorType.networkError.rawValue) \(error?.localizedDescription ?? "")", code: statusCode, hasError: error != nil) : nil
                let response = ChatResponse(uniqueId: request.uniqueId, result: data, error: error)
                self?.chat.delegate?.chatEvent(event: .map(.image(response)))
                completion?(response)
            }
    }

    func reverse(_ request: MapReverseRequest) {
        let urlString = "\(chat.config.mapServer)\(Routes.mapReverse.rawValue)"
        var url = URL(string: urlString)!
        url.appendQueryItems(with: request)
        let headers = ["Api-Key": chat.config.mapApiKey!]
        let bodyData = request.data
        var urlReq = URLRequest(url: url)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            if let result: ChatResponse<MapReverse> = self?.chat.session.decode(data, response, error) {
                self?.chat.responseQueue.async {
                    self?.chat.delegate?.chatEvent(event: .map(.reverse(result)))
                }
            }
        }
        .resume()
    }

    func routes(_ request: MapRoutingRequest) {
        let urlString = "\(chat.config.mapServer)\(Routes.mapRouting.rawValue)"
        var url = URL(string: urlString)!
        url.appendQueryItems(with: request)
        let headers = ["Api-Key": chat.config.mapApiKey!]
        let bodyData = request.data
        var urlReq = URLRequest(url: url)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            let result: ChatResponse<MapRoutingResponse>? = self?.chat.session.decode(data, response, error)
            self?.chat.responseQueue.async {
                let response = ChatResponse(uniqueId: request.uniqueId, result: result?.result?.routes, error: result?.error)
                self?.chat.delegate?.chatEvent(event: .map(.routes(response)))
            }
        }
        .resume()
    }

    func search(_ request: MapSearchRequest) {
        let urlString = "\(chat.config.mapServer)\(Routes.mapSearch.rawValue)"
        var url = URL(string: urlString)!
        url.appendQueryItems(with: request)
        let headers = ["Api-Key": chat.config.mapApiKey!]
        let bodyData = request.data
        var urlReq = URLRequest(url: url)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            let result: ChatResponse<MapSearchResponse>? = self?.chat.session.decode(data, response, error)
            self?.chat.responseQueue.async {
                let response = ChatResponse(uniqueId: request.uniqueId, result: result?.result?.items, error: result?.error)
                self?.chat.delegate?.chatEvent(event: .map(.search(response)))
            }
        }
        .resume()
    }
}
