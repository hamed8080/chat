//
// SystemProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import ChatDTO
import Foundation

@ChatGlobalActor
public protocol SystemProtocol: AnyObject {
    /// Send a event to the participants of a thread that you are typing something.
    /// - Parameter threadId: The id of the thread.
    func sendStartTyping(threadId: Int)

    /// Send user stop typing.
    func sendStopTyping()

    /// Notify some system actions such as upload a file, record a voice and e.g.
    /// - Parameter req: A request that contains the type of request and a threadId.
    func sendSignalMessage(_ req: SendSignalMessageRequest)
}

@ChatGlobalActor
protocol InternalSystemProtocol: AnyObject {
    /// A variable that determines how many times the user is typing is sent to the other participants.
    var isTypingCount: Int { get set }

    /// The timer for sending user is typing.
    var timerTyping: TimerProtocol? { get set }

    /// A timer to stop user is typing event.
    var timerCheckUserStoppedTyping: TimerProtocol? { get set }
}
