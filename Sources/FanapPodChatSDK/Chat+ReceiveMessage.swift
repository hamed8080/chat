//
// Chat+ReceiveMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

/// A factory class that delivers a message that is received to the client completion handler or an event delegate.
extension Chat {
    func invokeCallback(asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        if let typeCode = chatMessage.typeCode, typeCode != config.typeCode {
            logger?.log(title: "mismatch typeCode", message: "expected typeCode is:\(config.typeCode) but receive: \(chatMessage.typeCode ?? "")")
            return
        }
        logger?.log(title: "on Receive Message", jsonString: asyncMessage.string)

        switch chatMessage.type {
        case .addParticipant:
            onAddParticipant(asyncMessage)
        case .allUnreadMessageCount:
            onUnreadMessageCount(asyncMessage)
        case .block:
            onBlockContact(asyncMessage)
        case .botMessage:
            onBotMessage(asyncMessage)
        case .changeType: // TODO: not implemented yet!
            break
        case .clearHistory:
            onClearHistory(asyncMessage)
        case .closeThread:
            onCloseThread(asyncMessage)
        case .contactsLastSeen:
            onUsersLastSeen(asyncMessage)
        case .createBot:
            onCreateBot(asyncMessage)
        case .createThread:
            onCreateThread(asyncMessage)
        case .defineBotCommand:
            onAddBotCommand(asyncMessage)
        case .deleteMessage:
            onDeleteMessage(asyncMessage)
        case .delivery:
            onDeliverMessage(asyncMessage)
        case .seen:
            onSeenMessage(asyncMessage)
        case .sent:
            onSentMessage(asyncMessage)
        case .editMessage:
            onEditMessage(asyncMessage)
        case .forwardMessage:
            break
        case .getBlocked:
            onBlockedContacts(asyncMessage)
        case .getContacts:
            onContacts(asyncMessage)
        case .getCurrentUserRoles:
            onUserRoles(asyncMessage)
        case .getHistory:
            onGetHistroy(asyncMessage)
        case .messageDeliveredToParticipants:
            onMessageDeliveredToParticipants(asyncMessage)
        case .getMessageSeenParticipants:
            onMessageSeenByParticipants(asyncMessage)
        case .getNotSeenDuration:
            onContactNotSeen(asyncMessage)
        case .getReportReasons: // TODO: not implemented yet!
            break
        case .getStatus: // TODO: not implemented yet!
            break
        case .getThreads:
            onThreads(asyncMessage)
        case .isNameAvailable:
            onIsThreadNamePublic(asyncMessage)
        case .joinThread:
            onJoinThread(asyncMessage)
        case .lastMssageSeenUpdated:
            onLastSeenUpdate(asyncMessage)
        case .leaveThread:
            onLeaveThread(asyncMessage)
        case .logout:
            break
        case .message:
            onNewMessage(asyncMessage)
        case .ping:
            break
        case .pinThread, .unpinThread:
            onPinUnPinThread(asyncMessage)
        case .relationInfo: // TODO: not implemented yet!
            break
        case .removedFromThread:
            onUserRemovedFromThread(asyncMessage)
        case .removeParticipant:
            onRemoveParticipants(asyncMessage)
        case .removeRoleFromUser:
            onRemveUserRoles(asyncMessage)
        case .rename: // TODO: not implemented yet!
            break
        case .reportMessage:
            break
        case .reportThread:
            break
        case .reportUser:
            break
        case .setProfile:
            onSetProfile(asyncMessage)
        case .setRuleToUser:
            onUserRoles(asyncMessage)
        case .spamPvThread:
            onSpamThread(asyncMessage)
        case .startBot, .stopBot:
            onStartStopBot(asyncMessage)
        case .lastMessageDeleted:
            onLastMessageDeleted(asyncMessage)
        case .lastMessageEdited:
            onLastMessageEdited(asyncMessage)
        case .statusPing:
            onStatusPing(asyncMessage)
        case .systemMessage:
            onSystemMessageEvent(asyncMessage)
        case .threadInfoUpdated:
            onUpdateThreadInfo(asyncMessage)
        case .threadParticipants:
            onThreadParticipants(asyncMessage)
        case .unblock:
            onUnBlockContact(asyncMessage)
        case .muteThread, .unmuteThread:
            onMuteUnMuteThread(asyncMessage)
        case .pinMessage, .unpinMessage:
            onPinUnPinMessage(asyncMessage)
        case .contactSynced:
            onSyncContacts(asyncMessage)
        case .updateThreadInfo:
            onUpdateThreadInfo(asyncMessage)
        case .userInfo:
            onUserInfo(asyncMessage)
        case .registerAssistant:
            onRegisterAssistants(asyncMessage)
        case .deacticveAssistant:
            onDeactiveAssistants(asyncMessage)
        case .getAssistants:
            onAssistants(asyncMessage)
        case .getAssistantHistory:
            onAssistantHistory(asyncMessage)
        case .blockedAssistnts:
            onGetBlockedAssistants(asyncMessage)
        case .blockAssistant, .unblockAssistant:
            onBlockUnBlockAssistant(asyncMessage)
        case .mutualGroups:
            onMutalGroups(asyncMessage)
        case .userStatus: // TODO: not implemented yet!
            break
        case .removeBotCommands:
            onRemoveBotCommand(asyncMessage)
        case .getUserBots:
            onBots(asyncMessage)
        case .changeThreadType:
            onChangeThreadType(asyncMessage)
        case .tagList:
            onTags(asyncMessage)
        case .createTag:
            onCreateTag(asyncMessage)
        case .editTag:
            onEditTag(asyncMessage)
        case .deleteTag:
            onDeleteTag(asyncMessage)
        case .addTagParticipants:
            onAddTagParticipant(asyncMessage)
        case .removeTagParticipants:
            onRemoveTagParticipants(asyncMessage)
        case .getTagParticipants:
            onTagParticipants(asyncMessage)
        case .exportChats:
            onExportMessages(asyncMessage)
        case .deleteThread:
            onDeleteThread(asyncMessage)
        case .archiveThread, .unarchiveThread:
            onArchiveUnArchiveThread(asyncMessage)
        case .startCallRequest, .groupCallRequest:
            onStartCall(asyncMessage)
        case .cancelCall:
            onCancelCall(asyncMessage)
        case .acceptCall, .endCallRequest, .addCallParticipant, .terminateCall:
            // TODO: These methods aren't implemented yet by the SDK.
            break
        case .deliveredCallRequest:
            onDeliverCall(asyncMessage)
        case .callStarted:
            onCallStarted(asyncMessage)
        case .callParticipantJoined:
            onJoinCallParticipant(asyncMessage)
        case .removeCallParticipant:
            onRemoveCallParticipant(asyncMessage)
        case .muteCallParticipant, .unmuteCallParticipant:
            onMuteChanged(asyncMessage)
        case .turnOnVideoCall, .turnOffVideoCall:
            onVideoCallChanged(asyncMessage)
        case .leaveCall:
            onCallParticipantLeft(asyncMessage)
        case .callSessionCreated:
            onCallSessionCreated(asyncMessage)
        case .startRecording, .stopRecording:
            onCallRecordingChanged(asyncMessage)
        case .endCall:
            onCallEnded(asyncMessage)
        case .activeCallParticipants:
            onActiveCallParticipants(asyncMessage)
        case .getCalls:
            onCallsHistory(asyncMessage)
        case .callClientErrors:
            onCallError(asyncMessage)
        case .getCallsToJoin:
            onJoinCalls(asyncMessage)
        case .renewCallRequest:
            onRenewCall(asyncMessage)
        case .callInquiry:
            onCallInquiry(asyncMessage)
        case .cancelGroupCall:
            onGroupCallCanceled(asyncMessage)
        case .callStickerSystemMessage:
            onCallSticker(asyncMessage)
        case .error:
            onError(asyncMessage)
        case .unknown:
            logger?.log(title: "CHAT_SDK:", message: "an unknown message type received from the server not implemented in SDK!")
        }
    }
}
