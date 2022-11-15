//
// ReceiveMessageFactory.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

/// A factory class that delivers a message that is received to the client completion handler or an event delegate.
class ReceiveMessageFactory {
    class func invokeCallback(asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        if let typeCode = chatMessage.typeCode, typeCode != Chat.sharedInstance.config?.typeCode {
            Chat.sharedInstance.logger?.log(title: "mismatch typeCode", message: "expected typeCode is:\(Chat.sharedInstance.config?.typeCode ?? "") but receive: \(chatMessage.typeCode ?? "")")
            return
        }
        Chat.sharedInstance.logger?.log(title: "on Receive Message", jsonString: asyncMessage.string)

        switch chatMessage.type {
        case .addParticipant:
            AddParticipantResponseHandler.handle(asyncMessage)
        case .allUnreadMessageCount:
            AllUnreadMessageCountResponseHandler.handle(asyncMessage)
        case .block:
            BlockedResponseHandler.handle(asyncMessage)
        case .botMessage:
            BotMessageResponseHandler.handle(asyncMessage)
        case .changeType: // TODO: not implemented yet!
            break
        case .clearHistory:
            ClearHistoryResponseHandler.handle(asyncMessage)
        case .closeThread:
            CloseThreadResponseHandler.handle(asyncMessage)
        case .contactsLastSeen:
            ContactsLastSeenResponseHandler.handle(asyncMessage)
        case .createBot:
            CreateBotResponseHandler.handle(asyncMessage)
        case .createThread:
            CreateThreadResponseHandler.handle(asyncMessage)
        case .defineBotCommand:
            CreateBotCommandResposneHandler.handle(asyncMessage)
        case .deleteMessage:
            DeleteMessageResposneHandler.handle(asyncMessage)
        case .delivery:
            DeliverMessageResponseHandler.handle(asyncMessage)
        case .editMessage:
            EditMessageResponseHandler.handle(asyncMessage)
        case .forwardMessage:
            break
        case .getBlocked:
            BlockedContactsResponseHandler.handle(asyncMessage)
        case .getContacts:
            ContactsResponseHandler.handle(asyncMessage)
        case .getCurrentUserRoles:
            CurrentUserRolesResponseHandler.handle(asyncMessage)
        case .getHistory:
            HistoryResponseHandler.handle(asyncMessage)
        case .getMessageDeleveryParticipants:
            MessageDeliveredUsersResponseHandler.handle(asyncMessage)
        case .getMessageSeenParticipants:
            MessageSeenByUsersResponseHandler.handle(asyncMessage)
        case .getNotSeenDuration:
            ContactNotSeenDurationHandler.handle(asyncMessage)
        case .getReportReasons: // TODO: not implemented yet!
            break
        case .getStatus: // TODO: not implemented yet!
            break
        case .getThreads:
            ThreadsResponseHandler.handle(asyncMessage)
        case .isNameAvailable:
            IsPublicThreadNameAvailableResponseHandler.handle(asyncMessage)
        case .joinThread:
            JoinThreadResponseHandler.handle(asyncMessage)
        case .lastSeenUpdated:
            break
        case .leaveThread:
            LeaveThreadResponseHandler.handle(asyncMessage)
        case .logout:
            break
        case .message:
            MessageResponseHandler.handle(asyncMessage)
        case .muteThread:
            MuteThreadResponseHandler.handle(asyncMessage)
        case .ping:
            break
        case .pinMessage:
            PinMessageResponseHandler.handle(asyncMessage)
        case .pinThread:
            PinThreadResponseHandler.handle(asyncMessage)
        case .relationInfo: // TODO: not implemented yet!
            break
        case .removedFromThread:
            UserRemovedFromThreadServerAction.handle(asyncMessage)
        case .removeParticipant:
            RemoveParticipantResponseHandler.handle(asyncMessage)
        case .removeRoleFromUser:
            UserRemoveRolesResponseHandler.handle(asyncMessage)
        case .rename: // TODO: not implemented yet!
            break
        case .reportMessage:
            break
        case .reportThread:
            break
        case .reportUser:
            break
        case .seen:
            SeenMessageResponseHandler.handle(asyncMessage)
        case .sent:
            SentMessageResponseHandler.handle(asyncMessage)
        case .setProfile:
            SetProfileResponseHandler.handle(asyncMessage)
        case .setRuleToUser:
            UserRolesResponseHandler.handle(asyncMessage)
        case .spamPvThread:
            SpamPvThreadResponseHandler.handle(asyncMessage)
        case .startBot:
            StartBotResponseHandler.handle(asyncMessage)
        case .lastMessageDeleted:
            LastMessageDeletedHandler.handle(asyncMessage)
        case .lastMessageEdited:
            LastMessageEditedHandler.handle(asyncMessage)
        case .statusPing:
            // never triggered because no reponse back from server
            StatusPingResponseHandler.handle(asyncMessage)
        case .stopBot:
            StopBotResponseHandler.handle(asyncMessage)
        case .systemMessage:
            SystemMessageResponseHandler.handle(asyncMessage)
        case .threadInfoUpdated:
            UpdateThreadInfoResponseHandler.handle(asyncMessage)
        case .threadParticipants:
            ThreadParticipantsResponseHandler.handle(asyncMessage)
        case .unblock:
            UnBlockResponseHandler.handle(asyncMessage)
        case .unmuteThread:
            // same as Mute response no neeed new class to handle it
            MuteThreadResponseHandler.handle(asyncMessage)
        case .unpinMessage:
            UnPinMessageResponseHandler.handle(asyncMessage)
        case .unpinThread:
            // same as Pin response no neeed new class to handle it
            PinThreadResponseHandler.handle(asyncMessage)
        case .contactSynced:
            ContactsSyncedResponseHandler.handle(asyncMessage)
        case .updateThreadInfo:
            UpdateThreadInfoResponseHandler.handle(asyncMessage)
        case .userInfo:
            UserInfoResponseHandler.handle(asyncMessage)
        case .registerAssistant:
            RegisterAssistantsResponseHandler.handle(asyncMessage)
        case .deacticveAssistant:
            DeactiveAssistantsResponseHandler.handle(asyncMessage)
        case .getAssistants:
            AssistantsResponseHandler.handle(asyncMessage)
        case .getAssistantHistory:
            AssistantsHistoryResponseHandler.handle(asyncMessage)
        case .blockedAssistnts:
            BlockedAssistantsResponseHandler.handle(asyncMessage)
        case .blockAssistant, .unblockAssistant:
            BlockUnblockAssistantsResponseHandler.handle(asyncMessage)
        case .mutualGroups:
            MutualGroupsResponseHandler.handle(asyncMessage)
        case .userStatus: // TODO: not implemented yet!
            break
        case .removeBotCommands:
            RemoveBotCommandResposneHandler.handle(asyncMessage)
        case .getUserBots:
            UserBotsResposneHandler.handle(asyncMessage)
        case .changeThreadType:
            ChangeThreadTypeResposneHandler.handle(asyncMessage)
        case .tagList:
            TagListResponseHandler.handle(asyncMessage)
        case .createTag:
            CreateTagResponseHandler.handle(asyncMessage)
        case .editTag:
            EditTagResponseHandler.handle(asyncMessage)
        case .deleteTag:
            DeleteTagResponseHandler.handle(asyncMessage)
        case .addTagParticipants:
            AddTagParticipantsResponseHandler.handle(asyncMessage)
        case .removeTagParticipants:
            RemoveTagParticipantsResponseHandler.handle(asyncMessage)
        case .getTagParticipants:
            // TODO: Need to be add by server
            break
        case .exportChats:
            ExportResponseHandler.handle(asyncMessage)
        case .deleteThread:
            DeleteThreadResponseHandler.handle(asyncMessage)
        case .archiveThread:
            ArchiveThreadResponseHandler.handle(asyncMessage)
        case .unarchiveThread:
            UNArchiveThreadResponseHandler.handle(asyncMessage)
        case .error:
            ErrorResponseHandler.handle(asyncMessage)
        case .unknown:
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "an unknown message type received from the server not implemented in SDK!")
        }
    }
}
