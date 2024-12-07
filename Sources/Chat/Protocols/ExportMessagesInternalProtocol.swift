//
// ExportMessagesInternalProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatModels
import ChatCore

@ChatGlobalActor
public protocol ExportMessagesInternalProtocol: AnyObject {
    var chat: ChatImplementation { get set }
    var request: GetHistoryRequest { get set }
    var threadId: Int { get }
    var fileName: String { get }
    var titles: String { get }
    var fileManager: FileManager { get }
    var rootPath: URL { get }
    var filePath: URL { get }
    var maxSize: Int { get }
    var maxAvailableCount: Int { get }
    func start()
    func finished(success: Bool, uniqueId: String?, error: ChatError?, typeCode: String?)
    func hasNext(response: ChatResponse<[Message]>) -> Bool
    func setNextOffest()
    func addMessagesToFile(_ messages: [Message])
    func writeToFile(_ data: Data?)
    func createFile()
    func deleteFileIfExist()
    func sanitize(_ value: String) -> String
    func convertMessageToStringRow(_ message: Message) -> String
    func onReceive(_ response: ChatResponse<[Message]>)
}
