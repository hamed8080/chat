//
//  ReceiveMessage.swift
//  Chat
//
//  Created by Mahyar Zhiani on 6/4/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//
//import Foundation
//import SwiftyJSON
//
//
//
////#######################################################################################
////#############################
////#######################################################################################
//
//
//
//class ReceiveMessageClass {
//
//    public weak var delegate: ReceiveMessageClassDelegates?
//
//    var threadId: Int?
//    var type: Int
//    var subjectId: Int
//    var content: String
//    var contentCount: Int
//    var uniqueId: String
//    var time: Int
//
//    init(threadId: Int?, type: Int, subjectId: Int, content: String, contentCount: Int, uniqueId: String, time: Int) {
//        self.threadId = threadId
//        self.type = type
//        self.subjectId = subjectId
//
//        self.content = content
//        self.contentCount = contentCount
//        self.uniqueId = uniqueId
//        self.time = time
//
//        receivedMessageHandler()
//    }
//
//
//
//}
//
//
//extension ReceiveMessageClass {
//
//    func receivedMessageHandler() {
//        switch type {
//        case chatMessageVOTypes.CREATE_THREAD.rawValue:
//            //
//            break
//        case chatMessageVOTypes.MESSAGE.rawValue:
//            //
//            break
//        case chatMessageVOTypes.SENT.rawValue:
//            //
//            break
//        case chatMessageVOTypes.DELIVERY.rawValue:
//            //
//            break
//        case chatMessageVOTypes.SEEN.rawValue:
//            //
//            break
//        case chatMessageVOTypes.PING.rawValue:
//            //
//            break
//        case chatMessageVOTypes.LEAVE_THREAD.rawValue:
//            //
//            break
//        case chatMessageVOTypes.RENAME.rawValue:
//            //
//            break
//        case chatMessageVOTypes.ADD_PARTICIPANT.rawValue:
//            //
//            break
//        case chatMessageVOTypes.GET_CONTACTS.rawValue:
//            //
//            break
//        case chatMessageVOTypes.GET_THREADS.rawValue:
//            //
//            break
//        case chatMessageVOTypes.GET_HISTORY.rawValue:
//            //
//            break
//        case chatMessageVOTypes.REMOVED_FROM_THREAD.rawValue:
//            //
//            break
//        case chatMessageVOTypes.REMOVE_PARTICIPANT.rawValue:
//            //
//            break
//        case chatMessageVOTypes.MUTE_THREAD.rawValue:
//            //
//            break
//        case chatMessageVOTypes.UNMUTE_THREAD.rawValue:
//            //
//            break
//        case chatMessageVOTypes.FORWARD_MESSAGE.rawValue:
//            //
//            break
//        case chatMessageVOTypes.USER_INFO.rawValue:
//            let myData = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: content, contentCount: nil)
//            delegate?.onResult(type: 23, uniqueId: uniqueId, threadId: threadId, result: myData)
//            break
//        case chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue:
//            //
//            break
//        case chatMessageVOTypes.EDIT_MESSAGE.rawValue:
//            //
//            break
//        case chatMessageVOTypes.DELETE_MESSAGE.rawValue:
//            //
//            break
//        case chatMessageVOTypes.THREAD_INFO_UPDATED.rawValue:
//            //
//            break
//        case chatMessageVOTypes.LAST_SEEN_UPDATED.rawValue:
//            //
//            break
//        case chatMessageVOTypes.ERROR.rawValue:
//            //
//            break
//        default:
//            //
//            break
//        }
//    }
//
//
//
//
//
//    func createReturnData(hasError: Bool, errorMessage: String?, errorCode: Int?, result: Any, contentCount: Int?) -> JSON {
//
//        let hasErr = hasError
//        let myResult = result
//        let errMsg: String
//        var errCode: Int
//        var contCount: Int
//        if let theErrMsg = errorMessage {
//            errMsg = theErrMsg
//        } else {
//            errMsg = ""
//        }
//        if let errC = errorCode {
//            errCode = errC
//        } else {
//            errCode = 0
//        }
//        if let theCount = contentCount {
//            contCount = theCount
//        } else {
//            contCount = 0
//        }
//
//        let obj: JSON = ["hasError": hasErr, "errorMessage": errMsg, "errorCode": errCode, "result": myResult, "contentCount": contCount]
//        return obj
//    }
//
//}
//
//
//protocol ReceiveMessageClassDelegates: class {
//    func onResult(type: Int, uniqueId: String, threadId: Int?, result: JSON)
//    func onSent()
//    func onDelivere()
//    func onSeen()
//}

























