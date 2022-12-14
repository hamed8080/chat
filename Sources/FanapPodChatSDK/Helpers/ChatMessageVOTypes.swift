//
// ChatMessageVOTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public enum ChatMessageVOTypes: Int, Codable, SafeDecodable {
    case createThread = 1
    case message = 2
    case sent = 3
    case delivery = 4
    case seen = 5
    case ping = 6
    case block = 7
    case unblock = 8
    case leaveThread = 9
    case rename = 10 // not implemented yet!
    case addParticipant = 11
    case getStatus = 12 // not implemented yet!
    case getContacts = 13
    case getThreads = 14
    case getHistory = 15
    case changeType = 16 // not implemented yet!
    case removedFromThread = 17
    case removeParticipant = 18
    case muteThread = 19
    case unmuteThread = 20
    case updateThreadInfo = 21
    case forwardMessage = 22
    case userInfo = 23
    case userStatus = 24 // not implemented yet!
    case getBlocked = 25
    case relationInfo = 26 // not implemented yet!
    case threadParticipants = 27
    case editMessage = 28
    case deleteMessage = 29
    case threadInfoUpdated = 30
    case lastMssageSeenUpdated = 31
    case messageDeliveredToParticipants = 32
    case getMessageSeenParticipants = 33
    case isNameAvailable = 34
    case joinThread = 39
    case botMessage = 40
    case spamPvThread = 41
    case setRuleToUser = 42
    case removeRoleFromUser = 43
    case clearHistory = 44
    case systemMessage = 46
    case getNotSeenDuration = 47
    case pinThread = 48
    case unpinThread = 49
    case pinMessage = 50
    case unpinMessage = 51
    case setProfile = 52
    case changeThreadType = 53
    case getCurrentUserRoles = 54
    case getReportReasons = 56 // not implemented yet!
    case reportThread = 57
    case reportUser = 58
    case reportMessage = 59
    case contactsLastSeen = 60
    case allUnreadMessageCount = 61
    case createBot = 62
    case defineBotCommand = 63
    case startBot = 64
    case stopBot = 65
    case lastMessageDeleted = 66
    case lastMessageEdited = 67
    case contactSynced = 90
    case logout = 100
    case statusPing = 101
    case closeThread = 102
    case removeBotCommands = 104
    case registerAssistant = 107
    case deacticveAssistant = 108
    case getAssistants = 109
    case getAssistantHistory = 115
    case blockAssistant = 116
    case unblockAssistant = 117
    case blockedAssistnts = 118
    case getUserBots = 120
    case mutualGroups = 130
    case deleteThread = 151

    case createTag = 140
    case editTag = 141
    case deleteTag = 142
    case addTagParticipants = 143
    case removeTagParticipants = 144
    case tagList = 145
    case getTagParticipants = -4

    case exportChats = 152
    case archiveThread = 223
    case unarchiveThread = 224

    case error = 999

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case unknown
}
