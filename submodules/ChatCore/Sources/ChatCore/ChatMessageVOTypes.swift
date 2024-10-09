//
// ChatMessageVOTypes.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Additive
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
    case threadContactNameUpdated = 220
    case archiveThread = 223
    case unarchiveThread = 224
    case threadsUnreadCount = 233
    case addReaction = 239
    case replaceReaction = 240
    case removeReaction = 241
    case reactionList = 242
    case getReaction = 243
    case reactionCount = 244
    case customizeReactions = 245
    case replyPrivately = 238
    case setAdminRoleToUser = 250
    case removeAdminRoleFromUser = 251
    case lastActionInThread = 252
    case addUserToUserGroup = 253
    case allowedReactions = 255

    // CALL
    case startCallRequest = 70
    case acceptCall = 71 // never called from server events
    case cancelCall = 72
    case deliveredCallRequest = 73
    case callStarted = 74
    case endCallRequest = 75
    case endCall = 76
    case getCalls = 77
    case groupCallRequest = 91
    case leaveCall = 92
    case addCallParticipant = 93
    case callParticipantJoined = 94
    case removeCallParticipant = 95
    case terminateCall = 96 // never called from server events
    case muteCallParticipant = 97
    case unmuteCallParticipant = 98
    case cancelGroupCall = 99
    case activeCallParticipants = 110
    case callSessionCreated = 111
    case turnOnVideoCall = 113
    case turnOffVideoCall = 114
    case startRecording = 121
    case stopRecording = 122
    case getCallsToJoin = 129
    case callClientErrors = 153
    case callStickerSystemMessage = 225
    case renewCallRequest = 227
    case callInquiry = 228

    case error = 999

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case unknown
}
