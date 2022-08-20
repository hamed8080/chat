//
//  ReceiveMessageFactory.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import FanapPodAsyncSDK

class ReceiveMessageFactory{
	
    class func invokeCallback(asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else{return}
        if let typeCode = chatMessage.typeCode, typeCode != Chat.sharedInstance.config?.typeCode {
            Chat.sharedInstance.logger?.log(title: "mismatch typeCode", message: "expected typeCode is:\(Chat.sharedInstance.config?.typeCode ?? "") but receive: \(chatMessage.typeCode ?? "")")
            return
        }
        Chat.sharedInstance.logger?.log(title: "on Receive Message", jsonString: asyncMessage.string)
		
		switch chatMessage.type {
			
			case .ADD_PARTICIPANT:
				AddParticipantResponseHandler.handle(asyncMessage)
				break
			case .ALL_UNREAD_MESSAGE_COUNT:
				AllUnreadMessageCountResponseHandler.handle(asyncMessage)
				break
			case .BLOCK:
				BlockedResponseHandler.handle(asyncMessage)
				break
			case .BOT_MESSAGE:
                BotMessageResponseHandler.handle(asyncMessage)
				break
			case .CHANGE_TYPE://TODO: not implemented yet!
				break
			case .CLEAR_HISTORY:
                ClearHistoryResponseHandler.handle(asyncMessage)
				break
			case .CLOSE_THREAD:
				CloseThreadResponseHandler.handle(asyncMessage)
				break
			case .CONTACTS_LAST_SEEN:
                ContactsLastSeenResponseHandler.handle(asyncMessage)
				break
			case .CREATE_BOT:
				CreateBotResponseHandler.handle(asyncMessage)
				break
			case .CREATE_THREAD:
				CreateThreadResponseHandler.handle(asyncMessage)
				break
			case .DEFINE_BOT_COMMAND:
				CreateBotCommandResposneHandler.handle(asyncMessage)
				break
			case .DELETE_MESSAGE:
                DeleteMessageResposneHandler.handle(asyncMessage)
				break
			case .DELIVERY:
                DeliverMessageResponseHandler.handle(asyncMessage)
				break
			case .EDIT_MESSAGE:
                EditMessageResponseHandler.handle(asyncMessage)
				break
			case .FORWARD_MESSAGE:
				break
			case .GET_BLOCKED:
				BlockedContactsResponseHandler.handle(asyncMessage)
				break
			case .GET_CONTACTS:
				ContactsResponseHandler.handle(asyncMessage)
				break
			case .GET_CURRENT_USER_ROLES:
                CurrentUserRolesResponseHandler.handle(asyncMessage)
				break
			case .GET_HISTORY:
				HistoryResponseHandler.handle(asyncMessage)
				break
			case .GET_MESSAGE_DELEVERY_PARTICIPANTS:
				MessageDeliveredUsersResponseHandler.handle(asyncMessage)
				break
			case .GET_MESSAGE_SEEN_PARTICIPANTS:
				MessageSeenByUsersResponseHandler.handle(asyncMessage)
				break
			case .GET_NOT_SEEN_DURATION:
				ContactNotSeenDurationHandler.handle(asyncMessage)
				break
			case .GET_REPORT_REASONS://TODO: not implemented yet!
				break
			case .GET_STATUS://TODO: not implemented yet!
				break
			case .GET_THREADS:
				ThreadsResponseHandler.handle(asyncMessage)
				break
			case .IS_NAME_AVAILABLE:
				IsPublicThreadNameAvailableResponseHandler.handle(asyncMessage)
				break
			case .JOIN_THREAD:
				JoinThreadResponseHandler.handle(asyncMessage)
				break
			case .LAST_SEEN_UPDATED:
				break
			case .LEAVE_THREAD:
                LeaveThreadResponseHandler.handle(asyncMessage)
				break
			case .LOGOUT:
				break
			case .MESSAGE:
                MessageResponseHandler.handle(asyncMessage)
				break
			case .MUTE_THREAD:
				MuteThreadResponseHandler.handle(asyncMessage)
				break
			case .PING:
				break
			case .PIN_MESSAGE:
                PinMessageResponseHandler.handle(asyncMessage)
				break
			case .PIN_THREAD:
				PinThreadResponseHandler.handle(asyncMessage)
				break
			case .RELATION_INFO://TODO: not implemented yet!
				break
			case .REMOVED_FROM_THREAD:
                UserRemovedFromThreadServerAction.handle(asyncMessage)
				break
			case .REMOVE_PARTICIPANT:
				RemoveParticipantResponseHandler.handle(asyncMessage)
				break
			case .REMOVE_ROLE_FROM_USER:
                UserRemoveRolesResponseHandler.handle(asyncMessage)
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
                SeenMessageResponseHandler.handle(asyncMessage)
				break
			case .SENT:
                SentMessageResponseHandler.handle(asyncMessage)
				break
			case .SET_PROFILE:
				SetProfileResponseHandler.handle(asyncMessage)
				break
			case .SET_RULE_TO_USER:
                UserRolesResponseHandler.handle(asyncMessage)
				break
			case .SPAM_PV_THREAD:
                SpamPvThreadResponseHandler.handle(asyncMessage)
				break
			case .START_BOT:
				StartBotResponseHandler.handle(asyncMessage)
				break
			case .STATUS_PING:
				//never triggered because no reponse back from server
				StatusPingResponseHandler.handle(asyncMessage)
				break
			case .STOP_BOT:
				StopBotResponseHandler.handle(asyncMessage)
				break
			case .SYSTEM_MESSAGE:
                SystemMessageResponseHandler.handle(asyncMessage)
				break
			case .THREAD_INFO_UPDATED:
                UpdateThreadInfoResponseHandler.handle(asyncMessage)
				break
			case .THREAD_PARTICIPANTS:
				ThreadParticipantsResponseHandler.handle(asyncMessage)
				break
			case .UNBLOCK:
				UnBlockResponseHandler.handle(asyncMessage)
				break
			case .UNMUTE_THREAD:
				//same as Mute response no neeed new class to handle it
				MuteThreadResponseHandler.handle(asyncMessage)
				break
			case .UNPIN_MESSAGE:
                UnPinMessageResponseHandler.handle(asyncMessage)
				break
			case .UNPIN_THREAD:
				//same as Pin response no neeed new class to handle it
				PinThreadResponseHandler.handle(asyncMessage)
				break
            case .CONTACT_SYNCED:
                ContactsSyncedResponseHandler.handle(asyncMessage)
                break
			case .UPDATE_THREAD_INFO:
                UpdateThreadInfoResponseHandler.handle(asyncMessage)
				break
			case .USER_INFO:
				UserInfoResponseHandler.handle(asyncMessage)
				break
            case .REGISTER_ASSISTANT:
                RegisterAssistantsResponseHandler.handle(asyncMessage)
                break
            case .DEACTICVE_ASSISTANT:
                DeactiveAssistantsResponseHandler.handle(asyncMessage)
                break
            case .GET_ASSISTANTS:
                AssistantsResponseHandler.handle(asyncMessage)
                break
            case .GET_ASSISTANT_HISTORY:
                AssistantsHistoryResponseHandler.handle(asyncMessage)
                break
            case .BLOCKED_ASSISTNTS:
                BlockedAssistantsResponseHandler.handle(asyncMessage)
                break
            case .BLOCK_ASSISTANT , .UNBLOCK_ASSISTANT:
                BlockUnblockAssistantsResponseHandler.handle(asyncMessage)
                break
            case .MUTUAL_GROUPS:
                MutualGroupsResponseHandler.handle(asyncMessage)
                break
			case .USER_STATUS: //TODO: not implemented yet!
				break
            case .REMOVE_BOT_COMMANDS:
                RemoveBotCommandResposneHandler.handle(asyncMessage)
                break
            case .GET_USER_BOTS:
                UserBotsResposneHandler.handle(asyncMessage)
                break
            case .CHANGE_THREAD_TYPE:
                ChangeThreadTypeResposneHandler.handle(asyncMessage)
                break
            case .TAG_LIST:
                TagListResponseHandler.handle(asyncMessage)
                break
            case .CREATE_TAG:
                CreateTagResponseHandler.handle(asyncMessage)
                break
            case .EDIT_TAG:
                EditTagResponseHandler.handle(asyncMessage)
                break
            case .DELETE_TAG:
                DeleteTagResponseHandler.handle(asyncMessage)
                break
            case .ADD_TAG_PARTICIPANTS:
                AddTagParticipantsResponseHandler.handle(asyncMessage)
                break
            case .REMOVE_TAG_PARTICIPANTS:
                RemoveTagParticipantsResponseHandler.handle(asyncMessage)
                break
            case .GET_TAG_PARTICIPANTS:
                //TODO: Need to be add by server
                break
            case .EXPORT_CHATS:
                ExportResponseHandler.handle(asyncMessage)
                break
            case .DELETE_THREAD:
                DeleteThreadResponseHandler.handle(asyncMessage)
                break
			case .ERROR:
				ErrorResponseHandler.handle(asyncMessage)
				break
            case .CUSTOMER_INFO:
                CustomerInfoResponseHandler.handle(asyncMessage)
                break
            case .UNKNOWN:
                Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "an unknown message type received from the server not implemented in SDK!")
                break
			@unknown default :
                Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "an message received with unknowned type value. investigate to fix or leave that.")
		}
		
	}
}
