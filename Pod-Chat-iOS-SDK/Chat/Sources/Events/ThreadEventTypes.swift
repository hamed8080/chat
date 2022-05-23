//
//  ThreadEventTypes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//


import Foundation

public enum ThreadEventTypes {
    case THREAD_CLOSED(threadId:Int)
    case THREAD_UNREAD_COUNT_UPDATED(threadId:Int, count:Int)
    case THREAD_LAST_ACTIVITY_TIME(time:Int, threadId:Int?)
    case THREAD_PIN(threadId:Int)
    case THREAD_UNPIN(threadId:Int)
    case THREAD_INFO_UPDATED(Conversation)
    case THREAD_USER_ROLE(threadId:Int, roles:[UserRole])
    case THREAD_ADD_PARTICIPANTS(thread:Conversation, [Participant]?)
    case THREAD_LEAVE_SAFTLY_FAILED(threadId:Int)
    case THREAD_LEAVE_PARTICIPANT(User)
    case THREAD_REMOVED_FROM(threadId:Int)
    case THREAD_MUTE(threadId:Int)
    case THREAD_UNMUTE(threadId:Int)
    case THREADS_LIST_CHANGE([Conversation])
    case THREAD_PARTICIPANTS_LIST_CHANGE(threadId:Int?, [Participant])
    case THREAD_NEW(Conversation)
    case THREAD_REMOVE_PARTICIPANTS([Participant])
    case MESSAGE_PIN(threadId:Int?, PinUnpinMessage)
    case MESSAGE_UNPIN(threadId:Int?, PinUnpinMessage)
}
