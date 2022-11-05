//
// ExportRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import AVFoundation
import Foundation

class ExportRequestHandler {
    static var exportMessageViewModels: [any ExportMessagesProtocol] = []
    class func handle(_ req: GetHistoryRequest,
                      _: Chat,
                      _ completion: @escaping CompletionType<URL>,
                      _: UniqueIdResultType = nil)
    {
        let vm = ExportMessages(request: req, completion: completion)
        vm.start()
        exportMessageViewModels.append(vm)
    }
}

protocol ExportMessagesProtocol {
    var request: GetHistoryRequest { get set }
    var completion: CompletionType<URL> { get }
    var threadId: Int { get }
    var fileName: String { get }
    var titles: String { get }
    var fileManager: FileManager { get }
    var rootPath: URL { get }
    var filePath: URL { get }
    var maxSize: Int { get }
    var maxAvailableCount: Int { get }
    func start()
    func finished(success: Bool, uniqueId: String?, error: ChatError?)
    func removeCallbacks(_ uniqueId: String?)
    func hasNext(response: ChatResponse) -> Bool
    func setNextOffest()
    func addMessagesToFile(_ messages: [Message])
    func writeToFile(_ data: Data?)
    func createFile()
    func deleteFileIfExist()
    func sanitize(_ value: String) -> String
    func convertMessageToStringRow(_ message: Message) -> String
}

class ExportMessages: ExportMessagesProtocol {
    var request: GetHistoryRequest
    var completion: CompletionType<URL>
    var uniqueIdResult: UniqueIdResultType
    var threadId: Int { request.threadId }
    var fileName: String { "export-\(threadId).csv" }
    var fileManager: FileManager { FileManager.default }
    var rootPath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
    var filePath: URL { rootPath.appendingPathComponent(fileName) }
    let maxSize: Int = 10000
    var maxAvailableCount: Int = 0
    var titles: String { ["message", "userName", "name", "hour", "date"].map(\.localized).joined(separator: ",").appending("\r\n") }

    init(request: GetHistoryRequest, completion: @escaping CompletionType<URL>, uniqueIdResult: UniqueIdResultType = nil) {
        self.request = request
        self.completion = completion
        self.uniqueIdResult = uniqueIdResult
    }

    /// To prevent not sending a request with larger data or lower data.
    /// If it sends with lower data it causes thousands of requests, and if sent with larger data it will download a large chunk of data which may lead to corrupt the file and network problems.
    func start() {
        request.count = 500
        createFile()
        getHistory()
    }

    func getHistory() {
        Chat.sharedInstance.prepareToSendAsync(
            req: request,
            clientSpecificUniqueId: request.uniqueId,
            subjectId: threadId,
            messageType: .exportChats,
            uniqueIdResult: uniqueIdResult,
            completion: onReceive(_:)
        )
    }

    func onReceive(_ response: ChatResponse) {
        if let messages = response.result as? [Message] {
            addMessagesToFile(messages)
            if hasNext(response: response) {
                getHistory()
            } else {
                finished(success: true, uniqueId: response.uniqueId, error: response.error)
            }
        } else {
            finished(uniqueId: response.uniqueId, error: response.error ?? ChatError(code: .exportError, errorCode: 0, message: nil, rawError: response.error?.rawError))
        }
    }

    func removeCallbacks(_ uniqueId: String?) {
        ExportRequestHandler.exportMessageViewModels.removeAll(where: { $0.threadId == threadId })
        guard let uniqueId = uniqueId else { return }
        Chat.sharedInstance.callbacksManager.removeCallback(uniqueId: uniqueId, requestType: .exportChats)
    }

    func finished(success: Bool = false, uniqueId: String?, error: ChatError?) {
        completion(success ? filePath : nil, uniqueId, error)
        removeCallbacks(uniqueId)
    }

    func addMessagesToFile(_ messages: [Message]) {
        let string = messages.map { convertMessageToStringRow($0) }.joined()
        writeToFile(string.data(using: .utf8))
    }

    func writeToFile(_ data: Data?) {
        guard let data = data else { return }
        fileManager.appendToEndOfFile(data: data, fileurl: filePath)
    }

    func createFile() {
        deleteFileIfExist()
        fileManager.createFile(atPath: filePath.path, contents: titles.data(using: .utf8))
    }

    func deleteFileIfExist() {
        if fileManager.fileExists(atPath: filePath.path) {
            try? fileManager.removeItem(atPath: filePath.path)
        }
    }

    func sanitize(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: " "))\""
    }

    func convertMessageToStringRow(_ message: Message) -> String {
        var string = ""
        let sender = message.participant?.name ?? message.participant?.contactName ?? "\(message.participant?.firstName ?? "") \(message.participant?.lastName ?? "")"
        let date = Date(timeIntervalSince1970: TimeInterval(message.time ?? 0) / 1000)
        string.append(contentsOf: "\(sanitize(message.message ?? "")),")
        string.append(contentsOf: "\(sanitize(message.participant?.username ?? "undefined".localized)),")
        string.append(contentsOf: "\(sanitize(sender)),")
        string.append(contentsOf: "\(date.getTime(localIdentifire: Locale.current.identifier)),")
        string.append(contentsOf: "\(date.getDate(localIdentifire: Locale.current.identifier))")
        string.append(contentsOf: "\r\n")
        return string
    }

    func hasNext(response: ChatResponse) -> Bool {
        maxAvailableCount = min(maxSize, response.contentCount)
        setNextOffest()
        return request.offset < maxAvailableCount
    }

    func setNextOffest() {
        request.offset += request.count
    }
}
