//
// MapManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatDTO
import ChatModels
import ChatTransceiver
import Foundation

final class MapManager: MapProtocol {
    private typealias MapResultType<T> = (data: Data, res: URLResponse, decoded: T?)
    private let chat: ChatInternalProtocol
    
    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }
    
    func image(_ request: MapStaticImageRequest) async throws -> Data? {
        let request = MapStaticImageRequest(request: request, key: chat.config.mapApiKey)
        let url = "\(chat.config.mapServer)\(Routes.mapStaticImage.rawValue)"
        let params = DownloadManagerParameters(url: URL(string: url)!, token: chat.config.token, params: try? request.asSendableDictionary(), typeCodeIndex: request.typeCodeIndex, uniqueId: request.uniqueId)
        let session = chat.session
        let req = DownloadManager.urlRequest(params: params)
        let (data, _) = try await session.data(req)
        return data
    }
    
    func reverse(_ request: MapReverseRequest) async throws -> MapReverse? {
        let _ = urlReq(request: request, path: .mapReverse)
        let mres: MapResultType<MapReverse> = try await doRequest(request: request, path: .mapSearch)
        return mres.decoded
    }
    
    func routes(_ request: MapRoutingRequest) async throws -> [Route]? {
        let mres: MapResultType<MapRoutingResponse> = try await doRequest(request: request, path: .mapRouting)
        return mres.decoded?.routes
    }
    
    func search(_ request: MapSearchRequest) async throws -> [MapItem]? {
        let mres: MapResultType<MapSearchResponse> = try await doRequest(request: request, path: .mapSearch)
        return mres.decoded?.items
    }
    
    private func urlReq(request: Encodable, path: Routes) -> URLRequest {
        let urlString = "\(chat.config.mapServer)\(path.rawValue)"
        var url = URL(string: urlString)!
        url.appendQueryItems(with: request)
        let headers = ["Api-Key": chat.config.mapApiKey!]
        var urlReq = URLRequest(url: url)
        urlReq.allHTTPHeaderFields = headers
        urlReq.method = .get
        return urlReq
    }
    
    private func doRequest<T: Decodable>(request: Encodable & ChatDTO.TypeCodeIndexProtocol, path: Routes) async throws -> MapResultType<T> {
        let urlReq = urlReq(request: request, path: path)
        let session = chat.session
        let (data, response) = try await session.data(urlReq)
        let decodedResult: T = try data.decode()
        return (data, response, decodedResult)
    }
}
