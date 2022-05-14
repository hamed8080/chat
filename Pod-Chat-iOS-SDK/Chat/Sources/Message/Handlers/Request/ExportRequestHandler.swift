//
//  ExportRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
import AVFoundation

class ExportRequestHandler {
    
    static var totalMessages :[Message] = []
    static var maxCount                 = 10000
    static var localIdentifire          = "en_US"
    
    class func handle( _ req:GetHistoryRequest,
                       _ localIdentifire:String = "en_US",
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<URL>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        req.count = 500
        ExportRequestHandler.localIdentifire = localIdentifire
        totalMessages = [] //clear
        getHistory(req, chat, completion, uniqueIdResult)
    }
    
    class func getHistory(
                           _ req:GetHistoryRequest,
                           _ chat:Chat,
                           _ completion: @escaping CompletionType<URL>,
                           _ uniqueIdResult: UniqueIdResultType = nil
    ){
//
//        fakeRetriveData(offset: 0) { messages in
//            totalMessages.append(contentsOf: messages)
//        }
//

        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                subjectId: req.threadId,
                                messageType: .EXPORT_CHATS,
                                uniqueIdResult: uniqueIdResult){ response in

            if let messages = response.result as? [Message]{
                appendMessages(messages)
                maxCount = min(10000, response.contentCount)
                let endOffset = min(req.offset + req.count, maxCount)
                if req.offset < endOffset {
                    req.offset = req.offset + req.count
                    getHistory(req, chat, completion)
                }else{
                    let url = createFile(req.threadId)
                    completion(url,response.uniqueId, response.error)
                    if let uniqueId = response.uniqueId{
                        chat.callbacksManager.removeCallback(uniqueId: uniqueId, requestType: .EXPORT_CHATS)
                    }
                }
            }else{
                completion(nil,response.uniqueId, response.error ?? ChatError(code: .EXPORT_ERROR, errorCode: 0, message: nil, rawError: response.error?.rawError))
            }
        }
    }
    
    class func appendMessages(_ messages:[Message]){
        totalMessages.append(contentsOf: messages)
    }
    
    class func createFile(_ threadId:Int)->URL?{
        let titles = createTitles()
        let messagesString = createMessages()
        let url = createCVFile(threadId,titles, messagesString)
        return url
    }
    
    class func createTitles()->String{
        return ["تاریخ","ساعت","نام","نام کاربری","متن پیام"].joined(separator: ",")
    }
    
    class func createCVFile(_ threadId:Int, _ title:String, _ messagesString:String)->URL?{
        let fileName = "export-\(threadId).csv"
        let fm = FileManager.default
        if let directoryUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first{
            let fileURL = directoryUrl.appendingPathComponent(fileName)
            let filePath = fileURL.path
            if fm.fileExists(atPath: filePath){
                try? fm.removeItem(atPath: filePath)
            }
            fm.createFile(atPath: filePath, contents: (title + "\r\n" + messagesString).data(using: .utf8))
            let tmpUrl = try! fm.url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: fileURL,
                create: true
            ).appendingPathComponent("\(fileURL.lastPathComponent)")
            try! fm.moveItem(at: fileURL, to: tmpUrl)
            return tmpUrl
        }
        return nil
    }
    
    class func createMessages()->String{
        var messageRows = ""
        
        totalMessages.forEach { message in
           
            let sender = message.participant?.contactName ?? (message.participant?.firstName ?? "") + " " + (message.participant?.lastName ?? "")
            let date = Date(timeIntervalSince1970: TimeInterval(message.time ?? 0) / 1000)
            messageRows.append(contentsOf: "\(date.getDate(localIdentifire:localIdentifire)),")
            messageRows.append(contentsOf: "\(date.getTime(localIdentifire:localIdentifire)),")
            messageRows.append(contentsOf: "\(sender),")
            messageRows.append(contentsOf: "\(message.participant?.username ?? ""),")
            messageRows.append(contentsOf: "\(message.message ?? "")")
            messageRows.append(contentsOf: "\r\n")
        }
        return messageRows
    }
    
//    static var fakeMessages = generateMockMessages()
//
//    class func fakeRetriveData(offset:Int,part: @escaping ([Message])->()){
//
//        maxCount = fakeMessages.count
//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
//
//            if offset < maxCount{
//                part(Array(fakeMessages[offset..<(min(offset + 500, maxCount))]))
//                fakeRetriveData(offset: offset + 500, part: part)
//            }else{
//                createFile()
//            }
//        }
//    }
//
//    class func generateMockMessages()->[Message]{
//        var messages:[Message] = []
//        for i in 1...2209{
//            messages.append(Message(message:"Mock Message \(i)",time:1650138864, participant: .init(contactName:"Mock Contact Name\(i)", username: "Mock username\(i)")))
//        }
//        return messages
//    }
}
