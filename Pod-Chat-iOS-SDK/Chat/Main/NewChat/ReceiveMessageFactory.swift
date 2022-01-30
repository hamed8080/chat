//
//  ReceiveMessageFactory.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import FanapPodAsyncSDK

class ReceiveMessageFactory{
	
    class func invokeCallback(asyncMessage: NewAsyncMessage) {
		guard let chatMessageData  = asyncMessage.content?.data(using: .utf8) else{return}
		guard let chatMessage =  try? JSONDecoder().decode(NewChatMessage.self, from: chatMessageData) else{return}
        if let typeCode = chatMessage.typeCode, typeCode != Chat.sharedInstance.config?.typeCode {
            Chat.sharedInstance.logger?.log(title: "mismatch typeCode", message: "expected typeCode is:\(Chat.sharedInstance.config?.typeCode ?? "") but receive: \(chatMessage.typeCode ?? "")")
            return
        }
        Chat.sharedInstance.logger?.log(title: "on Receive Message", jsonString: asyncMessage.string)
		
		switch chatMessage.type {
			
			case .ADD_PARTICIPANT:
				AddParticipantResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .ALL_UNREAD_MESSAGE_COUNT:
				AllUnreadMessageCountResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .BLOCK:
				BlockedResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .BOT_MESSAGE:
                BotMessageResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .CHANGE_TYPE://TODO: not implemented yet!
				break
			case .CLEAR_HISTORY:
                ClearHistoryResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .CLOSE_THREAD:
				CloseThreadResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .CONTACTS_LAST_SEEN:
                ContactsLastSeenResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .CREATE_BOT:
				CreateBotResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .CREATE_THREAD:
				CreateThreadResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .DEFINE_BOT_COMMAND:
				CreateBotCommandResposneHandler.handle(chatMessage , asyncMessage)
				break
			case .DELETE_MESSAGE:
                DeleteMessageResposneHandler.handle(chatMessage , asyncMessage)
				break
			case .DELIVERY:
                DeliverMessageResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .EDIT_MESSAGE:
                EditMessageResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .FORWARD_MESSAGE:
				break
			case .GET_BLOCKED:
				BlockedContactsResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .GET_CONTACTS:
				ContactsResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .GET_CURRENT_USER_ROLES:
                CurrentUserRolesResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .GET_HISTORY:
				HistoryResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .GET_MESSAGE_DELEVERY_PARTICIPANTS:
				MessageDeliveredUsersResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .GET_MESSAGE_SEEN_PARTICIPANTS:
				MessageSeenByUsersResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .GET_NOT_SEEN_DURATION:
				ContactNotSeenDurationHandler.handle(chatMessage , asyncMessage)
				break
			case .GET_REPORT_REASONS://TODO: not implemented yet!
				break
			case .GET_STATUS://TODO: not implemented yet!
				break
			case .GET_THREADS:
				ThreadsResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .IS_NAME_AVAILABLE:
				IsPublicThreadNameAvailableResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .JOIN_THREAD:
				JoinThreadResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .LAST_SEEN_UPDATED:
				break
			case .LEAVE_THREAD:
                LeaveThreadResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .LOGOUT:
				break
			case .MESSAGE:
                MessageResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .MUTE_THREAD:
				MuteThreadResponseHandler.handle(chatMessage, asyncMessage)
				break
			case .PING:
                log.verbose("Message of type 'PING' recieved", context: "Chat") //TODO: must replace with new log
				break
			case .PIN_MESSAGE:
                PinMessageResponseHandler.handle(chatMessage, asyncMessage)
				break
			case .PIN_THREAD:
				PinThreadResponseHandler.handle(chatMessage, asyncMessage)
				break
			case .RELATION_INFO://TODO: not implemented yet!
				break
			case .REMOVED_FROM_THREAD:
                UserRemovedFromThreadServerAction.handle(chatMessage, asyncMessage)
				break
			case .REMOVE_PARTICIPANT:
				RemoveParticipantResponseHandler.handle(chatMessage, asyncMessage)
				break
			case .REMOVE_ROLE_FROM_USER:
                UserRemoveRolesResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .RENAME://TODO: not implemented yet!
				break
			case .REPORT_MESSAGE:
				break
			case .REPORT_THREAD:
				break
			case .REPORT_USER:
				break
			case .SEEN:
                SeenMessageResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .SENT:
                SentMessageResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .SET_PROFILE:
				SetProfileResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .SET_RULE_TO_USER:
                UserRolesResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .SPAM_PV_THREAD:
                SpamPvThreadResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .START_BOT:
				StartBotResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .STATUS_PING:
				//never triggered because no reponse back from server
				StatusPingResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .STOP_BOT:
				StopBotResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .SYSTEM_MESSAGE:
                SystemMessageResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .THREAD_INFO_UPDATED:
                UpdateThreadInfoResponseHandler.handle(chatMessage, asyncMessage)
				break
			case .THREAD_PARTICIPANTS:
				ThreadParticipantsResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .UNBLOCK:
				UnBlockResponseHandler.handle(chatMessage , asyncMessage)
				break
			case .UNMUTE_THREAD:
				//same as Mute response no neeed new class to handle it
				MuteThreadResponseHandler.handle(chatMessage, asyncMessage)
				break
			case .UNPIN_MESSAGE:
                UnPinMessageResponseHandler.handle(chatMessage, asyncMessage)
				break
			case .UNPIN_THREAD:
				//same as Pin response no neeed new class to handle it
				PinThreadResponseHandler.handle(chatMessage, asyncMessage)
				break
            case .CONTACT_SYNCED:
                ContactsSyncedResponseHandler.handle(chatMessage, asyncMessage)
                break
			case .UPDATE_THREAD_INFO:
                UpdateThreadInfoResponseHandler.handle(chatMessage, asyncMessage)
				break
			case .USER_INFO:
				UserInfoResponseHandler.handle(chatMessage, asyncMessage)
				break
            case .REGISTER_ASSISTANT:
                RegisterAssistantsResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .DEACTICVE_ASSISTANT:
                DeactiveAssistantsResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .GET_ASSISTANTS:
                AssistantsResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .GET_ASSISTANT_HISTORY:
                AssistantsHistoryResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .BLOCKED_ASSISTNTS:
                BlockedAssistantsResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .BLOCK_ASSISTANT , .UNBLOCK_ASSISTANT:
                BlockUnblockAssistantsResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .MUTUAL_GROUPS:
                MutualGroupsResponseHandler.handle(chatMessage, asyncMessage)
                break
			case .USER_STATUS: //TODO: not implemented yet!
				break
            case .REMOVE_BOT_COMMANDS:
                RemoveBotCommandResposneHandler.handle(chatMessage, asyncMessage)
                break
            case .GET_USER_BOTS:
                UserBotsResposneHandler.handle(chatMessage, asyncMessage)
                break
            case .CHANGE_THREAD_TYPE:
                ChangeThreadTypeResposneHandler.handle(chatMessage, asyncMessage)
                break
            case .TAG_LIST:
                TagListResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .CREATE_TAG:
                CreateTagResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .EDIT_TAG:
                EditTagResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .DELETE_TAG:
                DeleteTagResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .ADD_TAG_PARTICIPANTS:
                AddTagParticipantsResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .REMOVE_TAG_PARTICIPANTS:
                RemoveTagParticipantsResponseHandler.handle(chatMessage, asyncMessage)
                break
            case .GET_TAG_PARTICIPANTS:
                //TODO: Need to be add by server
                break
			case .ERROR:
				ErrorResponseHandler.handle(chatMessage , asyncMessage)
				break
            case .UNKNOWN:
                Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "an unknown message type received from the server not implemented in SDK!")
                break
			@unknown default :
                Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "an message received with unknowned type value. investigate to fix or leave that.")
		}
		
	}
}
