//
// ChatImplementation+ReceiveMessage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Foundation

/// A factory class that delivers a message that is received to the client completion handler or an event delegate.
public extension ChatImplementation {
    func invokeCallback(asyncMessage: AsyncMessage) async {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        if let typeCode = chatMessage.typeCode, config.typeCodes.first(where: { $0.typeCode == typeCode }) == nil {
            let message = "Expected the type codes to be one of the:\(config.typeCodes) but received: \(chatMessage.typeCode ?? "")"
            logger.log(title: "Mismatch typeCode", message: message, persist: true, type: .internalLog, userInfo: loggerUserInfo)
            return
        }
        logger.logJSON(title: "On Receive Message with type: \(chatMessage.type)", jsonString: asyncMessage.string ?? "", persist: false, type: .received)

        switch chatMessage.type {
        case .addParticipant:
             (conversation.participant as? ParticipantManager)?.onAddParticipant(asyncMessage)
        case .allUnreadMessageCount:
             (conversation as? ThreadManager)?.onUnreadMessageCount(asyncMessage)
        case .botMessage:
             (bot as? BotManager)?.onBotMessage(asyncMessage)
        case .changeType: // TODO: not implemented yet!
            break
        case .clearHistory:
             (message as? MessageManager)?.onClearHistory(asyncMessage)
        case .closeThread:
             (conversation as? ThreadManager)?.onCloseThread(asyncMessage)
        case .contactsLastSeen:
             (contact as? ContactManager)?.onUsersLastSeen(asyncMessage)
        case .createBot:
             (bot as? BotManager)?.onCreateBot(asyncMessage)
        case .createThread:
             (conversation as? ThreadManager)?.onCreateThread(asyncMessage)
        case .defineBotCommand:
             (bot as? BotManager)?.onAddBotCommand(asyncMessage)
        case .deleteMessage:
             (message as? MessageManager)?.onDeleteMessage(asyncMessage)
        case .delivery:
             (message as? MessageManager)?.onDeliverMessage(asyncMessage)
        case .seen:
             (message as? MessageManager)?.onSeenMessage(asyncMessage)
        case .sent:
             (message as? MessageManager)?.onSentMessage(asyncMessage)
        case .editMessage:
             (message as? MessageManager)?.onEditMessage(asyncMessage)
        case .forwardMessage:
            (message as? MessageManager)?.onForwardMessage(asyncMessage)
            (conversation as? ThreadManager)?.onForwardMessage(asyncMessage)
        case .getBlocked:
             await (contact as? ContactManager)?.onBlockedContacts(asyncMessage)
        case .getContacts:
             await (contact as? ContactManager)?.onContacts(asyncMessage)
        case .getCurrentUserRoles:
             (user as? UserManager)?.onCurrentUserRoles(asyncMessage)
             (conversation as? ThreadManager)?.onCurrentUserRoles(asyncMessage)
        case .getHistory:
            await (message as? MessageManager)?.onGetHistroy(asyncMessage)
        case .messageDeliveredToParticipants:
             (message as? MessageManager)?.onMessageDeliveredToParticipants(asyncMessage)
        case .getMessageSeenParticipants:
             (message as? MessageManager)?.onMessageSeenByParticipants(asyncMessage)
        case .getNotSeenDuration:
             (contact as? ContactManager)?.onContactNotSeen(asyncMessage)
        case .getReportReasons: // TODO: not implemented yet!
            break
        case .getStatus: // TODO: not implemented yet!
            break
        case .getThreads:
             (conversation as? ThreadManager)?.onThreads(asyncMessage)
        case .isNameAvailable:
             (conversation as? ThreadManager)?.onIsThreadNamePublic(asyncMessage)
        case .joinThread:
             (conversation as? ThreadManager)?.onJoinThread(asyncMessage)
        case .lastMssageSeenUpdated:
             (conversation as? ThreadManager)?.onLastSeenUpdate(asyncMessage)
        case .leaveThread:
             (conversation as? ThreadManager)?.onLeaveThread(asyncMessage)
        case .logout:
            break
        case .message:
             (message as? MessageManager)?.onNewMessage(asyncMessage)
             (reaction as? ReactionManager)?.onNewMessage(asyncMessage)
             (conversation as? ThreadManager)?.onNewMessage(asyncMessage)
        case .ping:
            break
        case .pinThread, .unpinThread:
             (conversation as? ThreadManager)?.onPinUnPinThread(asyncMessage)
        case .relationInfo: // TODO: not implemented yet!
            break
        case .removedFromThread:
             (conversation as? ThreadManager)?.onUserRemovedFromThread(asyncMessage)
        case .removeParticipant:
             (conversation.participant as? ParticipantManager)?.onRemoveParticipants(asyncMessage)
        case .removeRoleFromUser:
             (user as? UserManager)?.onRemveUserRoles(asyncMessage)
        case .rename: // TODO: not implemented yet!
            break
        case .reportMessage:
            break
        case .reportThread:
            break
        case .reportUser:
            break
        case .setProfile:
             (user as? UserManager)?.onSetProfile(asyncMessage)
        case .setRuleToUser:
             (user as? UserManager)?.onSetRolesToUser(asyncMessage)
        case .spamPvThread:
             (conversation as? ThreadManager)?.onSpamThread(asyncMessage)
        case .startBot, .stopBot:
             (bot as? BotManager)?.onStartStopBot(asyncMessage)
        case .lastMessageDeleted:
             (message as? MessageManager)?.onLastMessageDeleted(asyncMessage)
        case .lastMessageEdited:
             (message as? MessageManager)?.onLastMessageEdited(asyncMessage)
        case .statusPing:
             (user as? UserManager)?.onStatusPing(asyncMessage)
        case .systemMessage:
             (system as? SystemManager)?.onSystemMessageEvent(asyncMessage)
        case .threadParticipants:
             (conversation.participant as? ParticipantManager)?.onThreadParticipants(asyncMessage)
        case .unblock, .block:
             (contact as? ContactManager)?.onBlockUnBlockContact(asyncMessage)
        case .muteThread, .unmuteThread:
             (conversation as? ThreadManager)?.onMuteUnMuteThread(asyncMessage)
        case .pinMessage, .unpinMessage:
             (message as? MessageManager)?.onPinUnPinMessage(asyncMessage)
        case .contactSynced:
             (contact as? ContactManager)?.onSyncContacts(asyncMessage)
        case .updateThreadInfo:
             (conversation as? ThreadManager)?.onUpdateThreadInfo(asyncMessage)
        case .userInfo:
             (user as? UserManager)?.onUserInfo(asyncMessage)
        case .registerAssistant:
             (assistant as? AssistantManager)?.onRegisterAssistants(asyncMessage)
        case .deacticveAssistant:
             (assistant as? AssistantManager)?.onDeactiveAssistants(asyncMessage)
        case .getAssistants:
             (assistant as? AssistantManager)?.onAssistants(asyncMessage)
        case .getAssistantHistory:
             (assistant as? AssistantManager)?.onAssistantHistory(asyncMessage)
        case .blockedAssistnts:
             (assistant as? AssistantManager)?.onGetBlockedAssistants(asyncMessage)
        case .blockAssistant, .unblockAssistant:
             (assistant as? AssistantManager)?.onBlockUnBlockAssistant(asyncMessage)
        case .mutualGroups:
             (conversation as? ThreadManager)?.onMutalGroups(asyncMessage)
        case .userStatus: // TODO: not implemented yet!
            break
        case .removeBotCommands:
             (bot as? BotManager)?.onRemoveBotCommand(asyncMessage)
        case .getUserBots:
             (bot as? BotManager)?.onBots(asyncMessage)
        case .changeThreadType:
             (conversation as? ThreadManager)?.onChangeThreadType(asyncMessage)
        case .tagList:
             (tag as? TagManager)?.onTags(asyncMessage)
        case .createTag:
             (tag as? TagManager)?.onCreateTag(asyncMessage)
        case .editTag:
             (tag as? TagManager)?.onEditTag(asyncMessage)
        case .deleteTag:
             (tag as? TagManager)?.onDeleteTag(asyncMessage)
        case .addTagParticipants:
             (tag as? TagManager)?.onAddTagParticipant(asyncMessage)
        case .removeTagParticipants:
             (tag as? TagManager)?.onRemoveTagParticipants(asyncMessage)
        case .getTagParticipants:
             (tag as? TagManager)?.onTagParticipants(asyncMessage)
        case .exportChats:
             (message as? MessageManager)?.onExportMessages(asyncMessage)
        case .deleteThread:
             (conversation as? ThreadManager)?.onDeleteThread(asyncMessage)
        case .archiveThread, .unarchiveThread:
             (conversation as? ThreadManager)?.onArchiveUnArchiveThread(asyncMessage)
        case .threadsUnreadCount:
             (conversation as? ThreadManager)?.onThreadsUnreadCount(asyncMessage)
        case .threadContactNameUpdated:
             (conversation as? ThreadManager)?.onThreadNameContactUpdated(asyncMessage)
        case .startCallRequest,
             .acceptCall,
             .cancelCall,
             .deliveredCallRequest,
             .callStarted,
             .endCallRequest,
             .endCall,
             .getCalls,
             .groupCallRequest,
             .leaveCall,
             .addCallParticipant,
             .callParticipantJoined,
             .removeCallParticipant,
             .terminateCall,
             .muteCallParticipant,
             .unmuteCallParticipant,
             .cancelGroupCall,
             .activeCallParticipants,
             .callSessionCreated,
             .turnOnVideoCall,
             .turnOffVideoCall,
             .startRecording,
             .stopRecording,
             .getCallsToJoin,
             .callClientErrors,
             .callStickerSystemMessage,
             .renewCallRequest,
             .callInquiry:
             callMessageDeleaget?.onCallMessageDelegate(asyncMessage: asyncMessage, chat: self)
        case .getReaction:
             (reaction as? ReactionManager)?.onUserReaction(asyncMessage)
        case .reactionList:
             (reaction as? ReactionManager)?.onReactionList(asyncMessage)
        case .addReaction:
            await (reaction as? ReactionManager)?.onAddReaction(asyncMessage)
        case .replaceReaction:
            await (reaction as? ReactionManager)?.onReplaceReaction(asyncMessage)
        case .removeReaction:
            await (reaction as? ReactionManager)?.onDeleteReaction(asyncMessage)
        case .reactionCount:
             (reaction as? ReactionManager)?.onReactionCount(asyncMessage)
        case .lastActionInThread:
             (conversation as? ThreadManager)?.onLastActionInThread(asyncMessage)
        case .allowedReactions:
             (reaction as? ReactionManager)?.onAllowedReactions(asyncMessage)
        case .customizeReactions:
             (reaction as? ReactionManager)?.onCustomizeReactions(asyncMessage)
        case .replyPrivately:
            /// This action will not trigger by the server it just a send request.
            break
        case .setAdminRoleToUser:
             ((conversation as? ThreadManager)?.participant as? ParticipantManager)?.onSetAdminRoleToUser(asyncMessage)
        case .removeAdminRoleFromUser:
             ((conversation as? ThreadManager)?.participant as? ParticipantManager)?.onRemoveAdminRoleFromUser(asyncMessage)
        case .addUserToUserGroup:
             (file as? ChatFileManager)?.onAddUserToUserGroup(asyncMessage)
        case .error:
             (system as? SystemManager)?.onError(asyncMessage)
        case .unknown:
            logger.log(title: "CHAT_SDK:", message: "an unknown message type received from the server not implemented in SDK!", persist: true, type: .internalLog)
        }
    }
}
