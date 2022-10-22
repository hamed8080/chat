//
// ExportRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import AVFoundation
import Foundation

class ExportRequestHandler {
    static var maxCount = 10000
    static var localIdentifire = "en_US"

    class func handle(_ req: GetHistoryRequest,
                      _ localIdentifire: String = "en_US",
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<URL>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        req.count = 500
        ExportRequestHandler.localIdentifire = localIdentifire
        createFile(req.threadId)
        getHistory(req, chat, completion, uniqueIdResult)
    }

    class func getHistory(
        _ req: GetHistoryRequest,
        _ chat: Chat,
        _ completion: @escaping CompletionType<URL>,
        _ uniqueIdResult: UniqueIdResultType = nil
    ) {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.threadId,
                                messageType: .exportChats,
                                uniqueIdResult: uniqueIdResult) { response in

            if let messages = response.result as? [Message] {
                appendToFile(messages, req)

                maxCount = min(10000, response.contentCount)
                req.offset += req.offset
                if req.offset < maxCount {
                    getHistory(req, chat, completion)
                } else {
                    let url = fileUrl(for: req.threadId)
                    print("file exported at path:\(url?.path ?? "")")
                    completion(url, response.uniqueId, response.error)
                    if let uniqueId = response.uniqueId {
                        chat.callbacksManager.removeCallback(uniqueId: uniqueId, requestType: .exportChats)
                    }
                }
            } else {
                completion(nil, response.uniqueId, response.error ?? ChatError(code: .exportError, errorCode: 0, message: nil, rawError: response.error?.rawError))
            }
        }
    }

    class func createFile(_ threadId: Int) {
        let titles = createTitles()
        createCVFile(threadId, titles)
    }

    class func createTitles() -> String {
        ["تاریخ", "ساعت", "نام", "نام کاربری", "متن پیام"].joined(separator: ",")
    }

    class func appendToFile(_ messages: [Message], _ req: GetHistoryRequest) {
        guard let fileUrl = fileUrl(for: req.threadId),
              let data = createMessages(messages: messages).data(using: .utf8)
        else { return }
        FileManager.default.appendToEndOfFile(data: data, fileurl: fileUrl)
    }

    class func fileUrl(for threadId: Int) -> URL? {
        let fileName = "export-\(threadId).csv"
        let fm = FileManager.default
        if let directoryUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = directoryUrl.appendingPathComponent(fileName)
            return fileURL
        }
        return nil
    }

    class func createCVFile(_ threadId: Int, _ title: String) {
        let fm = FileManager.default
        if let fileURL = fileUrl(for: threadId) {
            let filePath = fileURL.path
            if fm.fileExists(atPath: filePath) {
                try? fm.removeItem(atPath: filePath)
            }
            fm.createFile(atPath: filePath, contents: (title + "\r\n").data(using: .utf8))
        }
    }

    class func sanitizeString(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: " "))\""
    }

    class func createMessages(messages: [Message]) -> String {
        var messageRows = ""

        messages.forEach { message in

            let sender = message.participant?.contactName ?? (message.participant?.firstName ?? "") + " " + (message.participant?.lastName ?? "")
            let date = Date(timeIntervalSince1970: TimeInterval(message.time ?? 0) / 1000)
            messageRows.append(contentsOf: "\(date.getDate(localIdentifire: localIdentifire)),")
            messageRows.append(contentsOf: "\(date.getTime(localIdentifire: localIdentifire)),")
            messageRows.append(contentsOf: "\(sanitizeString(sender)),")
            messageRows.append(contentsOf: "\(sanitizeString(message.participant?.username ?? "")),")
            messageRows.append(contentsOf: "\(sanitizeString(message.message ?? ""))")
            messageRows.append(contentsOf: "\r\n")
        }
        return messageRows
    }
}
