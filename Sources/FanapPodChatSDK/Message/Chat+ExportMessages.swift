//
// Chat+ExportMessages.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import AVFoundation
import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Every time you call this function old export file for the thread will be deleted and replaced with a new one. To manages your storage be cautious about removing the file whenever you don't need this file.
    /// This function can only export 10000 messages.
    /// - Parameters:
    ///   - request: A request that contains threadId and other filters to export.
    ///   - localIdentifire: The locals to output.
    ///   - completion: A file url of a csv file.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func exportChat(_ request: GetHistoryRequest, _ completion: @escaping CompletionTypeNoneDecodeable<URL>, uniqueIdResult _: UniqueIdResultType? = nil) {
        let vm = ExportMessages(chat: self, request: request, completion: completion)
        vm.start()
        exportMessageViewModels.append(vm)
    }
}

protocol ExportMessagesProtocol {
    var chat: Chat { get set }
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
    func hasNext(response: ChatResponse<[Message]>) -> Bool
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
    var uniqueIdResult: UniqueIdResultType?
    var threadId: Int { request.threadId }
    var fileName: String { "export-\(threadId).csv" }
    var fileManager: FileManager { FileManager.default }
    var rootPath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
    var filePath: URL { rootPath.appendingPathComponent(fileName) }
    let maxSize: Int = 10000
    var maxAvailableCount: Int = 0
    var titles: String { ["message", "userName", "name", "hour", "date"].map(\.localized).joined(separator: ",").appending("\r\n") }
    var chat: Chat

    init(chat: Chat, request: GetHistoryRequest, completion: @escaping CompletionTypeNoneDecodeable<URL>, uniqueIdResult: UniqueIdResultType? = nil) {
        self.request = request
        self.completion = completion
        self.uniqueIdResult = uniqueIdResult
        self.chat = chat
    }

    /// To prevent not sending a request with larger data or lower data.
    /// If it sends with lower data it causes thousands of requests, and if sent with larger data it will download a large chunk of data which may lead to corrupt the file and network problems.
    func start() {
        request.count = 500
        createFile()
        getHistory()
    }

    func getHistory() {
        request.chatMessageType = .exportChats
        chat.prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: onReceive(_:))
    }

    func onReceive(_ response: ChatResponse<[Message]>) {
        if let messages = response.result {
            addMessagesToFile(messages)
            if hasNext(response: response) {
                getHistory()
            } else {
                finished(success: true, uniqueId: response.uniqueId, error: response.error)
            }
        } else {
            finished(uniqueId: response.uniqueId, error: response.error ?? ChatError(type: .exportError, code: 0, message: nil, rawError: response.error?.rawError))
        }
    }

    func removeCallbacks(_ uniqueId: String?) {
        chat.exportMessageViewModels.removeAll(where: { $0.threadId == threadId })
        guard let uniqueId = uniqueId else { return }
        chat.callbacksManager.removeCallback(uniqueId: uniqueId, requestType: .exportChats)
    }

    func finished(success: Bool = false, uniqueId: String?, error: ChatError?) {
        completion(ChatResponse(uniqueId: uniqueId, result: success ? filePath : nil, error: error))
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

    func hasNext(response: ChatResponse<[Message]>) -> Bool {
        maxAvailableCount = min(maxSize, response.contentCount ?? 0)
        setNextOffest()
        return request.offset < maxAvailableCount
    }

    func setNextOffest() {
        request.offset += request.count
    }
}

// Response
extension Chat {
    func onExportMessages(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Message]> = asyncMessage.toChatResponse(context: persistentManager.context)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
