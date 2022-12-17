//
// CallbacksManager.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

class CallbacksManager {
    private var callbacks: [String: Any] = [:]
    private var callbacksRequestType: [String: ChatMessageVOTypes] = [:]
    private var sentCallbacks: [String: OnSentType?] = [:]
    private var deliveredCallbacks: [String: OnDeliveryType?] = [:]
    private var seenCallbacks: [String: OnSeenType?] = [:]
    private var uploadTasks: [String: URLSessionTask] = [:]
    private var downloadTasks: [String: URLSessionTask] = [:]

    func addCallback<T: Decodable>(uniqueId: String,
                                   requesType: ChatMessageVOTypes,
                                   callback: CompletionType<T>? = nil,
                                   onSent: OnSentType? = nil,
                                   onDelivered: OnDeliveryType? = nil,
                                   onSeen: OnSeenType? = nil)
    {
        if let callback = callback {
            callbacks[uniqueId] = callback
        }
        if let onSent = onSent {
            sentCallbacks[uniqueId] = onSent
        }
        if let onDelivered = onDelivered {
            deliveredCallbacks[uniqueId] = onDelivered
        }
        if let onSeen = onSeen {
            seenCallbacks[uniqueId] = onSeen
        }
        callbacksRequestType[uniqueId] = requesType
    }

    func removeCallback(uniqueId: String, requestType: ChatMessageVOTypes) {
        if callbacksRequestType[uniqueId] == requestType || requestType == .error {
            callbacks.removeValue(forKey: uniqueId)
        }
    }

    func removeSentCallback(uniqueId: String) {
        sentCallbacks.removeValue(forKey: uniqueId)
    }

    func removeDeliverCallback(uniqueId: String) {
        deliveredCallbacks.removeValue(forKey: uniqueId)
    }

    func removeSeenCallback(uniqueId: String) {
        seenCallbacks.removeValue(forKey: uniqueId)
    }

    func getCallBack<T: Decodable>(_ uniqueId: String) -> CompletionType<T>? {
        callbacks[uniqueId] as? CompletionType<T> ?? nil
    }

    func getSentCallback(_ uniqueId: String) -> OnSentType? {
        sentCallbacks[uniqueId] ?? nil
    }

    func getDeliverCallback(_ uniqueId: String) -> OnDeliveryType? {
        deliveredCallbacks[uniqueId] ?? nil
    }

    func getSeenCallback(_ uniqueId: String) -> OnSeenType? {
        seenCallbacks[uniqueId] ?? nil
    }

    func isUniqueIdExistInAllCllbacks(uniqueId: String) -> Bool {
        var allKeys: [String] = []
        allKeys.append(contentsOf: callbacks.keys)
        allKeys.append(contentsOf: sentCallbacks.keys)
        allKeys.append(contentsOf: seenCallbacks.keys)
        allKeys.append(contentsOf: deliveredCallbacks.keys)
        return allKeys.contains(uniqueId)
    }

    func getDownloadTask(uniqueId: String) -> URLSessionTask? {
        downloadTasks[uniqueId]
    }

    func getUploadTask(uniqueId: String) -> URLSessionTask? {
        uploadTasks[uniqueId]
    }

    func removeDownloadTask(uniqueId: String) {
        downloadTasks.removeValue(forKey: uniqueId)
    }

    func removeUploadTask(uniqueId: String) {
        uploadTasks.removeValue(forKey: uniqueId)
    }

    func addDownloadTask(task: URLSessionTask, uniqueId: String) {
        downloadTasks[uniqueId] = task
    }

    func addUploadTask(task: URLSessionTask, uniqueId: String) {
        uploadTasks[uniqueId] = task
    }

    func invokeAndRemove<T: Decodable>(_ response: ChatResponse<T>, _ type: ChatMessageVOTypes?) {
        guard let uniqueId = response.uniqueId,
              let type = type,
              let callback: CompletionType<T> = getCallBack(uniqueId) else { return }
        callback(ChatResponse(uniqueId: response.uniqueId, result: response.result))
        removeCallback(uniqueId: uniqueId, requestType: type)
    }
}
