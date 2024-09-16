//
//  File.swift
//  
//
//  Created by hamed on 9/16/24.
//

import Foundation
@testable import Chat
@testable import Logger

final class MockChatDelegate: ChatDelegate {
    var historyDelegate: ((ChatResponse<[Message]>) -> Void)?

    func chatState(state: ChatState, currentUser: User?, error: ChatError?) {

    }

    func chatEvent(event: ChatEventType) {
        switch event {
        case .message(let messageEvent):
            switch messageEvent {
            case .history(let chatResponse):
                historyDelegate?(chatResponse)
            default:
                break
            }
        default:
            break
        }
    }

    func onLog(log: Log) {

    }
}
