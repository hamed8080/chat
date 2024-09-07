//
// MapManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import ChatTransceiver
import Foundation

final class MapManager: InternalMapProtocol {
    let chat: ChatInternalProtocol
    private var session: URLSession?

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func image(_ request: MapStaticImageRequest) {
        image(request, nil)
    }

    func image(_ request: MapStaticImageRequest, _ completion: ((ChatResponse<Data>) -> Void)? = nil) {
        let request = MapStaticImageRequest(request: request, key: chat.config.mapApiKey)
        let url = "\(chat.config.mapServer)\(Routes.mapStaticImage.rawValue)"
        let typeCode = request.toTypeCode(chat)
        let params = DownloadManagerParameters(url: URL(string: url)!, token: chat.config.token, params: try? request.asDictionary(), uniqueId: request.uniqueId)

        let delegate = ProgressImplementation(uniqueId: params.uniqueId, uploadProgress: nil) { [weak self] progress in
            self?.chat.delegate?.chatEvent(event: .download(.progress(uniqueId: params.uniqueId, progress: progress)))
        } downloadCompletion: { [weak self] data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let error = error != nil ? ChatError(message: "\(ChatErrorType.networkError.rawValue) \(error?.localizedDescription ?? "")", code: statusCode, hasError: error != nil) : nil
            let response = ChatResponse(uniqueId: request.uniqueId, result: data, error: error, typeCode: typeCode)
            self?.chat.delegate?.chatEvent(event: .map(.image(response)))
            completion?(response)
            self?.session?.invalidateAndCancel()
        }
        session?.invalidateAndCancel()
        session = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)
        if let session = self.session {
            _ = DownloadManager.download(params, session)
        }
    }

    func reverse(_ request: MapReverseRequest) {
        reverse(request, nil)
    }

    func reverse(_ request: MapReverseRequest, _ completion: ((ChatResponse<MapReverse>) -> Void)? = nil) {
        let urlString = "\(chat.config.mapServer)\(Routes.mapReverse.rawValue)"
        var url = URL(string: urlString)!
        url.appendQueryItems(with: request)
        let headers = ["Api-Key": chat.config.mapApiKey!]
        var urlReq = URLRequest(url: url)
        urlReq.allHTTPHeaderFields = headers
        urlReq.method = .get
        let typeCode = request.toTypeCode(chat)
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            if let result: ChatResponse<MapReverse> = self?.chat.session.decode(data, response, error, typeCode: typeCode) {
                self?.chat.delegate?.chatEvent(event: .map(.reverse(result)))
                completion?(result)
            }
        }
        .resume()
    }

    func routes(_ request: MapRoutingRequest) {
        let urlString = "\(chat.config.mapServer)\(Routes.mapRouting.rawValue)"
        var url = URL(string: urlString)!
        url.appendQueryItems(with: request)
        let headers = ["Api-Key": chat.config.mapApiKey!]
        var urlReq = URLRequest(url: url)
        urlReq.allHTTPHeaderFields = headers
        urlReq.method = .get
        let typeCode = request.toTypeCode(chat)
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            let result: ChatResponse<MapRoutingResponse>? = self?.chat.session.decode(data, response, error, typeCode: typeCode)
            let response = ChatResponse(uniqueId: request.uniqueId, result: result?.result?.routes, error: result?.error, typeCode: typeCode)
            self?.chat.delegate?.chatEvent(event: .map(.routes(response)))
        }
        .resume()
    }

    func search(_ request: MapSearchRequest) {
        let urlString = "\(chat.config.mapServer)\(Routes.mapSearch.rawValue)"
        var url = URL(string: urlString)!
        url.appendQueryItems(with: request)
        let headers = ["Api-Key": chat.config.mapApiKey!]
        var urlReq = URLRequest(url: url)
        urlReq.allHTTPHeaderFields = headers
        urlReq.method = .get
        let typeCode = request.toTypeCode(chat)
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            let result: ChatResponse<MapSearchResponse>? = self?.chat.session.decode(data, response, error, typeCode: typeCode)
            let response = ChatResponse(uniqueId: request.uniqueId, result: result?.result?.items, error: result?.error, typeCode: typeCode)
            self?.chat.delegate?.chatEvent(event: .map(.search(response)))
        }
        .resume()
    }
}
