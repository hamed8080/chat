//
//  MessageEventTypes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//


import Foundation

public enum MessageEventTypes {
    case MESSAGE_NEW(Message)
    case MESSAGE_SEND(Message)
    case MESSAGE_DELIVERY(Message)
    case MESSAGE_SEEN(Message)
    case MESSAGE_EDIT(Message)
    case MESSAGE_DELETE(Message)
}
