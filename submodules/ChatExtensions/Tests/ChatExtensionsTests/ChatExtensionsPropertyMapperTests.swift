import XCTest
import Logger
import Mocks
import Additive
import ChatCore
import ChatDTO
import ChatModels
import ChatTransceiver
@testable import ChatExtensions

final class ChatExtensionsPropertyMapperTests: XCTestCase {
    
    func test_AddBotCommandRequestProperties() {
        let req = AddBotCommandRequest(botName: "")
        XCTAssertNil(req.content, "The content of the request should be nil")
    }

    func test_CreateBotRequestProperties() {
        let req = CreateBotRequest(botName: "TEST")
        XCTAssertEqual(req.botName, req.content ?? "", "The content should be equal to the botName.")
    }

    func test_GetUserBotsRequestProperties() {
        let req = GetUserBotsRequest()
        XCTAssertNil(req.content, "The content of the request should be nil")
    }

    func test_RemoveBotCommandRequestProperties() {
        let req = RemoveBotCommandRequest(botName: "TEST", commandList: ["TEST_COMMAND"])
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_StartStopBotRequestProperties() {
        let req = StartStopBotRequest(botName: "TEST", threadId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.subjectId, req.threadId, "The subjectId should be equal to threadId.")
    }

    func test_AcceptCallRequestProperties() {
        let req = AcceptCallRequest(callId: 1, client: .init(id: "TEST", type: .ios, deviceId: nil, mute: false, video: false, desc: nil))
        XCTAssertEqual(req.client.jsonString, req.content ?? "", "The content should be equal to a client.jsonString.")
        XCTAssertEqual(req.callId, req.subjectId, "The subjectId should be equal to callId.")
    }

    func test_AddCallParticipantsRequestProperties() {
        let req = AddCallParticipantsRequest(callId: 1, contactIds: [1, 2])
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.callId, req.subjectId, "The subjectId should be equal to callId.")
    }

    func test_CallClientErrorRequestProperties() {
        let req = CallClientErrorRequest(callId: 1, code: .cameraNotAvailable)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.callId, req.subjectId, "The subjectId should be equal to callId.")
    }

    func test_CallsHistoryRequestProperties() {
        let req = CallsHistoryRequest(count: 10, offset: 0, callIds: nil, type:.videoCall, name: nil, creatorCoreUserId: nil, creatorSsoId: nil, threadId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_CallStickerRequestProperties() {
        let req = CallStickerRequest(callId: 1, stickers: [.angry])
        XCTAssertEqual(req.stickers.jsonString, req.content ?? "", "The content should be equal to a stickers.jsonString.")
        XCTAssertEqual(req.callId, req.subjectId, "The subjectId should be equal to callId.")
    }

    func test_CancelCallRequestProperties() {
        let req = CancelCallRequest(call: .init(id: 1, creatorId: 1, type: .videoCall, isGroup: false))
        XCTAssertEqual(req.call.jsonString, req.content ?? "", "The content should be equal to a call.jsonString.")
        XCTAssertEqual(req.call.id, req.subjectId, "The subjectId should be equal to callId.")
    }

    func test_CreateCallThreadRequestProperties() {
        let req = CreateCallThreadRequest(title: "TEST", image: nil, description: nil, metadata: nil, uniqueName: nil)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_GetJoinCallsRequestProperties() {
        let req = GetJoinCallsRequest(threadIds: [1], offset: 0, count: 20, name: nil, type: .videoCall)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_MuteCallRequestProperties() {
        let req = MuteCallRequest(callId: 1, userIds: [1])
        XCTAssertEqual(req.userIds.jsonString, req.content ?? "", "The content should be equal to a userIds.jsonString.")
        XCTAssertEqual(req.callId, req.subjectId, "The subjectId should be equal to callId.")
    }

    func test_RemoveCallParticipantsRequestProperties() {
        let req = RemoveCallParticipantsRequest(callId: 1, userIds: [1])
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.callId, req.subjectId, "The subjectId should be equal to callId.")
    }

    func test_RenewCallRequestProperties() {
        let req = RenewCallRequest(invitees: [.init(id: "TEST", idType: .cellphoneNumber)], callId: 1)
        XCTAssertEqual(req.invitess.jsonString, req.content ?? "", "The content should be equal to a invitess.jsonString.")
        XCTAssertEqual(req.callId, req.subjectId, "The subjectId should be equal to callId.")
    }

    func test_StartCallRequestProperties() {
        let req = StartCallRequest(client: .init(id: "TEST", type: .ios, deviceId: nil, mute: false, video: false, desc: ""), contacts: [], thread: nil, threadId: nil, invitees: nil, type: .videoCall, groupName: "TEST", createCallThreadRequest: nil)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_UNMuteCallRequestProperties() {
        let req = UNMuteCallRequest(callId: 1, userIds: [1])
        XCTAssertEqual(req.userIds.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.callId, req.subjectId, "The subjectId should be equal to callId.")
    }

    func test_BlockedListRequestProperties() {
        let req = BlockedListRequest(count: 25, offset: 0)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_BlockRequestProperties() {
        let req = BlockRequest(contactId: 1, threadId: 1, userId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_ContactsRequestProperties() {
        let req = ContactsRequest(id: 1, count: 20, cellphoneNumber: nil, email: nil, coreUserId: 1, offset: 0, order: nil, query: nil, summery: nil)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.size, req.count, "The size should be equal to count.")
    }

    func test_whenConvertContactsRequestToFetchRequest_hasSameFields() {
        let req = ContactsRequest(id: 1, count: 20, cellphoneNumber: nil, email: nil, coreUserId: 1, offset: 0, order: .asc, query: nil, summery: nil)
        XCTAssertEqual(req.id, req.fetchRequest.id , "The id field of the fetchRequest should be equal to id filed of ContactsRequest.")
        XCTAssertEqual(req.count, req.fetchRequest.size , "The size field of the fetchRequest should be equal to count filed of ContactsRequest.")
        XCTAssertEqual(req.cellphoneNumber, req.fetchRequest.cellphoneNumber , "The cellphoneNumber field of the fetchRequest should be equal to cellphoneNumber filed of ContactsRequest.")
        XCTAssertEqual(req.email, req.fetchRequest.email , "The email field of the fetchRequest should be equal to email filed of ContactsRequest.")
        XCTAssertEqual(req.coreUserId, req.fetchRequest.coreUserId , "The coreUserId field of the fetchRequest should be equal to coreUserId filed of ContactsRequest.")
        XCTAssertEqual(req.offset, req.fetchRequest.offset , "The offset field of the fetchRequest should be equal to offset filed of ContactsRequest.")
        XCTAssertEqual(req.order ?? Ordering.asc.rawValue, req.fetchRequest.order , "The order field of the fetchRequest should be equal to order filed of ContactsRequest.")
        XCTAssertEqual(req.query, req.fetchRequest.query , "The query field of the fetchRequest should be equal to query filed of ContactsRequest.")
        XCTAssertEqual(req.summery, req.fetchRequest.summery , "The summery field of the fetchRequest should be equal to summery filed of ContactsRequest.")
        let req1 = ContactsRequest(id: 1, count: 20, cellphoneNumber: nil, email: nil, coreUserId: 1, offset: 0, order: nil, query: nil, summery: nil)
        XCTAssertEqual(req1.fetchRequest.order, Ordering.asc.rawValue, "The order field of the fetchRequest should be equal to order filed of ContactsRequest.")
    }

    func test_NotSeenDurationRequestProperties() {
        let req = NotSeenDurationRequest(userIds: [1])
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_UnBlockRequestProperties() {
        let req = UnBlockRequest(blockId: 1, contactId: 1, threadId: 1, userId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_AllThreadsUnreadCountRequestProperties() {
        let req = AllThreadsUnreadCountRequest(mute: true)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_BatchDeleteMessageRequestProperties() {
        let req = BatchDeleteMessageRequest(threadId: 1, messageIds: [1], deleteForAll: false)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_DeleteMessageRequestProperties() {
        let req = DeleteMessageRequest(deleteForAll: true, messageId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content of the DeleteMessageRequest should be equal to jsonString.")
        XCTAssertEqual(req.messageId, req.subjectId, "The subjectId of the DeleteMessageRequest should be equal to messageId.")
    }

    func test_EditMessageRequestProperties() {
        let req = EditMessageRequest(threadId: 1, messageType: .text, messageId: 1, textMessage: "TEST", repliedTo: nil, metadata: nil)
        XCTAssertEqual(req.textMessage, req.content ?? "", "The content should be equal to a textMessage.")
        XCTAssertEqual(req.messageId, req.subjectId, "The subjectId should be equal to messageId.")
    }

    func test_ForwardMessageRequestProperties() {
        let req = ForwardMessageRequest(fromThreadId: 1, threadId: 1, messageIds: [1])
        XCTAssertEqual("\(req.messageIds)", req.content ?? "", "The content should be equal to a messageIds.")
        XCTAssertEqual(req.threadId, req.subjectId, "The subjectId should be equal to threadId.")
    }

    func test_GetHistoryRequestProperties() {
        let req = GetHistoryRequest(threadId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The subjectId should be equal to threadId.")
    }

    func test_MentionRequestProperties() {
        let req = MentionRequest(threadId: 1, onlyUnreadMention: false, count: 20, offset: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The subjectId should be equal to threadId.")
    }

    func test_MessageDeliveredUsersRequestProperties() {
        let req = MessageDeliveredUsersRequest(messageId: 1, count: 25, offset: 0)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_MessageDeliverRequestProperties() {
        let req = MessageDeliverRequest(messageId: 1, threadId: 1)
        XCTAssertEqual(req.messageId, req.content ?? "", "The content should be equal to a messageId.")
    }

    func test_MessageSeenByUsersRequestProperties() {
        let req = MessageSeenByUsersRequest(messageId: 1, count: 20, offset: 0)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_MessageSeenRequestProperties() {
        let req = MessageSeenRequest(threadId: 1, messageId: 1)
        XCTAssertEqual("\(req.messageId)", req.content ?? "", "The content should be equal to a messageId.")
    }

    func test_PinUnpinMessageRequestProperties() {
        let req = PinUnpinMessageRequest(messageId: 1, notifyAll: false)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.messageId, req.subjectId, "The content should be equal to a messageId.")
    }

    func test_ReplyMessageRequestProperties() {
        let req = ReplyMessageRequest(threadId: 1, repliedTo: 0, textMessage: "TEST", messageType: .text, metadata: nil, systemMetadata: nil)
        XCTAssertEqual(req.textMessage, req.content ?? "", "The content should be equal to a textMessage.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
        XCTAssertEqual(req._messageType?.rawValue, req.messageType.rawValue, "The _messageType should be equal to _messageType.")
    }

    func test_SendSignalMessageRequestProperties() {
        let req = SendSignalMessageRequest(signalType: .isTyping, threadId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_SendTextMessageRequestProperties() {
        let req = SendTextMessageRequest(threadId: 1, textMessage: "TEST", messageType: .text)
        XCTAssertEqual(req.textMessage, req.content ?? "", "The content should be equal to a textMessage.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
        XCTAssertEqual(req._messageType?.rawValue, req.messageType.rawValue, "The _messageType should be equal to a messageType.")
        XCTAssertEqual(req.queueOfFileMessages(.init(data: Data())).threadId, req.subjectId, "The content should be equal to a threadId.")
        XCTAssertEqual(req.queueOfFileMessages(UploadImageRequest(data: Data(), mimeType: "jog")).threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_AddParticipantRequestProperties() {
        let req = AddParticipantRequest(contactIds: [1], threadId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_AddTagParticipantsRequestProperties() {
        let req = AddTagParticipantsRequest(tagId: 1, threadIds: [1])
        XCTAssertEqual(req.threadIds.jsonString, req.content ?? "", "The content should be equal to a threadIds.jsonString.")
        XCTAssertEqual(req.tagId, req.subjectId, "The content should be equal to a tagId.")
    }

    func test_AssistantsHistoryRequestProperties() {
        let req = AssistantsHistoryRequest(count: 20, offset: 0, actionType: .activate, fromTime: nil, toTime: nil)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_AssistantsRequestProperties() {
        let req = AssistantsRequest(contactType: "TEST", count: 20, offset: 0)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_BlockedAssistantsRequestProperties() {
        let req = BlockedAssistantsRequest(count: 20, offset: 0)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_BlockUnblockAssistantRequestProperties() {
        let req = BlockUnblockAssistantRequest(assistants: [.init(assistant: .init(id: "TEST", idType: .cellphoneNumber), roles: [.addNewUser])])
        XCTAssertEqual(req.assistants.jsonString, req.content ?? "", "The content should be equal to a assistants.jsonString.")
    }

    func test_ChangeThreadTypeRequestProperties() {
        let req = ChangeThreadTypeRequest(threadId: 1, type: .normal)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_CreateTagRequestProperties() {
        let req = CreateTagRequest(tagName: "TEST")
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_CreateThreadRequestProperties() {
        let req = CreateThreadRequest(title: "TEST")
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_CreateThreadWithMessageProperties() {
        let req = CreateThreadWithMessage(title: "TEST", message: .init(text: "TEST", messageType: .text))
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to a jsonString.")
    }

    func test_DeactiveAssistantRequestProperties() {
        let req = DeactiveAssistantRequest(assistants: [.init(assistant: .init(id: "TEST", idType: .cellphoneNumber), roles: [.addNewUser])])
        XCTAssertEqual(req.assistants.jsonString, req.content ?? "", "The content should be equal to a assistants.jsonString.")
    }

    func test_DeleteTagRequestProperties() {
        let req = DeleteTagRequest(id: 1)
        XCTAssertNil(req.content, "The content should be equal to nil.")
        XCTAssertEqual(req.id, req.subjectId, "The content should be equal to a id.")
    }

    func test_EditTagRequestProperties() {
        let req = EditTagRequest(id: 1, tagName: "TEST")
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to jsonString.")
        XCTAssertEqual(req.id, req.subjectId, "The content should be equal to a id.")
    }

    func test_GeneralSubjectIdRequestProperties() {
        let req = GeneralSubjectIdRequest(subjectId: 1)
        XCTAssertNil(req.content, "The content should be nil.")
        XCTAssertEqual(req._subjectId, req.subjectId, "The content should be equal to a _subjectId.")
    }

    func test_GetTagParticipantsRequestProperties() {
        let req = GetTagParticipantsRequest(id: 1)
        XCTAssertNil(req.content, "The content should be equal to nil.")
        XCTAssertEqual(req.id, req.subjectId, "The content should be equal to a id.")
    }

    func test_IsThreadNamePublicRequestProperties() {
        let req = IsThreadNamePublicRequest(name: "TEST")
        XCTAssertEqual(req.jsonString, req.content, "The content should be equal to jsonString.")
    }

    func test_JoinPublicThreadRequestProperties() {
        let req = JoinPublicThreadRequest(threadName: "TEST")
        XCTAssertEqual(req.threadName, req.content, "The content should be equal to threadName.")
    }

    func test_LeaveThreadRequestProperties() {
        let req = LeaveThreadRequest(threadId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_MutualGroupsRequestProperties() {
        let req = MutualGroupsRequest(toBeUser: .init(id: "TEST", idType: .cellphoneNumber))
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to jsonString.")
    }

    func test_RegisterAssistantsRequestProperties() {
        let req = RegisterAssistantsRequest(assistants: [.init(assistant: .init(id: "TEST", idType: .cellphoneNumber), roles: [.addNewUser])])
        XCTAssertEqual(req.assistants.jsonString, req.content ?? "", "The content should be equal to assistants.jsonString.")
    }

    func test_RemoveParticipantRequestProperties() {
        let req1 = RemoveParticipantRequest(invitess: [.init(id: "TEST", idType: .cellphoneNumber)], threadId: 1)
        XCTAssertEqual(req1.invitees?.jsonString ?? "", req1.content ?? "", "The content should be equal to assistants.jsonString.")

        let req2 = RemoveParticipantRequest(participantIds: [1], threadId: 1)
        XCTAssertEqual(req2.participantIds?.jsonString ?? "", req2.content ?? "", "The content should be equal to participantIds.jsonString.")

        XCTAssertEqual(req1.threadId, req1.subjectId, "The content should be equal to a threadId.")
    }

    func test_RemoveTagParticipantsRequestProperties() {
        let req = RemoveTagParticipantsRequest(tagId: 1, tagParticipants: [.init(id: 1)])
        XCTAssertEqual(req.tagParticipants.jsonString, req.content ?? "", "The content should be equal to tagParticipants.jsonString.")
        XCTAssertEqual(req.tagId, req.subjectId, "The content should be equal to a tagId.")
    }

    func test_SafeLeaveThreadRequestProperties() {
        let req = SafeLeaveThreadRequest(threadId: 1, participantId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_ThreadParticipantRequestProperties() {
        let req = ThreadParticipantRequest(threadId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_ThreadParticipantInitializerProperties() {
        let req = ThreadParticipantRequest(request: .init(threadId: 1), admin: true)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_ThreadsRequestProperties() {
        let req = ThreadsRequest(threadIds: [1])
        XCTAssertEqual(req.jsonString, req.content ?? "","The content should be equal to jsonString.")
        XCTAssertEqual(req.count, req.fetchRequest.count, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.offset, req.fetchRequest.offset, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.name, req.fetchRequest.title, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.name, req.fetchRequest.title, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.new, req.fetchRequest.new, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.isGroup, req.fetchRequest.isGroup, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.type?.rawValue, req.fetchRequest.type, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.archived, req.fetchRequest.archived, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.threadIds, req.fetchRequest.threadIds, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.creatorCoreUserId, req.fetchRequest.creatorCoreUserId, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.partnerCoreUserId, req.fetchRequest.partnerCoreUserId, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.partnerCoreContactId, req.fetchRequest.partnerCoreContactId, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.metadataCriteria, req.fetchRequest.metadataCriteria, "The value of the XCTAssertEqual in Thread should be equal")
        XCTAssertEqual(req.uniqueId, req.fetchRequest.uniqueId, "The value of the XCTAssertEqual in Thread should be equal")
    }

    func test_ThreadsUnreadCountRequestProperties() {
        let req = ThreadsUnreadCountRequest(threadIds: [1])
        XCTAssertEqual(req.threadIds.jsonString, req.content ?? "", "The content should be equal to threadIds.jsonString.")
    }

    func test_UpdateThreadInfoRequestProperties() {
        let req = UpdateThreadInfoRequest(threadId: 1, title: "TEST")
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_AuditorRequestProperties() {
        let req = AuditorRequest(userRoleRequest: .init(userId: 1, roles: [.addNewUser]), threadId: 1)
        XCTAssertEqual(req.userRoles.jsonString, req.content ?? "", "The content should be equal to userRoles.jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_RolesRequestProperties() {
        let req = RolesRequest(userRoles: [.init(userId: 1, roles: [.addNewUser])], threadId: 1)
        XCTAssertEqual(req.userRoles.jsonString, req.content ?? "", "The content should be equal to userRoles.jsonString.")
        XCTAssertEqual(req.threadId, req.subjectId, "The content should be equal to a threadId.")
    }

    func test_SendStatusPingRequestProperties() {
        let req = SendStatusPingRequest(statusType: .chat, threadId: 1)
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to jsonString.")
    }

    func test_UpdateChatProfileProperties() {
        let req = UpdateChatProfile(bio: "TEST")
        XCTAssertEqual(req.jsonString, req.content ?? "", "The content should be equal to jsonString.")
    }

    func test_UserInfoRequestProperties() {
        let req = UserInfoRequest()
        XCTAssertNil(req.content, "The content should be equal to be nil.")
    }

    func test_convertAContactToAddRequestContact() {
        let req = Contact(cellphoneNumber: "TEST", email: "TEST", firstName: "TEST", lastName: "TEST", user: .init(username: "TEST"))
        XCTAssertEqual(req.cellphoneNumber, req.request.cellphoneNumber, "The contact.cellphoneNumber should be equal to contact.cellphoneNumber.")
        XCTAssertEqual(req.email, req.request.email, "The contact.email should be equal to contact.email.")
        XCTAssertEqual(req.firstName, req.request.firstName, "The contact.firstName should be equal to contact.firstName.")
        XCTAssertEqual(req.lastName, req.request.lastName, "The contact.lastName should be equal to contact.lastName.")
        XCTAssertEqual(req.user?.username, req.request.username, "The contact.username should be equal to contact.username.")
    }

    func test_DownloadManagerParameters_hasImageURL() {
        let req = DownloadManagerParameters(ImageRequest(hashCode: "TEST"), mockConfig, nil)
        XCTAssertTrue(req.url.string?.contains("images") == true)
    }

    func test_DownloadManagerParameters_hasFileURL() {
        let req = DownloadManagerParameters(FileRequest(hashCode: "TEST"), mockConfig, nil)
        XCTAssertTrue(req.url.string?.contains("files") == true)
    }

    func test_messageHasMetadata() {
        let req = Message(metadata: FileMetaData(file: .init(fileExtension: "jpg", link: "TEST", mimeType: "image/application", name: "TEST", originalName: "TEST", size: 64, fileHash: "TEST", hashCode: "TEST", parentHash: "TEST", actualHeight: 128, actualWidth: 128)).jsonString)
        XCTAssertNotNil(req.fileMetaData, "The file metadata field of the message should not be nil.")
    }

    func test_messageHasInvalidMetadata_returnNilMetadata() {
        let req = Message(metadata: "INVALID_DATA")
        XCTAssertNil(req.fileMetaData, "The file metadata field of the message should be nil.")
    }

    func test_whenConvertEditMessageRequestToQueueOfEditMessages_itHasSameFields() {
        let req = QueueOfEditMessages(edit: .init(threadId: 1, messageType: .text, messageId: 1, textMessage: "TEST"))
        XCTAssertEqual("TEST", req.textMessage, "The textMessage field of the QueueOfEditMessages should not be equal to TETS.")
    }

    func test_whenConvertEditMessageRequestToQueueOfEditMessages_hasSameFields() {
        let req = EditMessageRequest(threadId: 1, messageType: .text, messageId: 1, textMessage: "TEST")
        XCTAssertEqual(req.messageType, req.queueOfTextMessages.messageType, "The messageType of QueueOfEditMessage shouold be equal to messageType EditMessageRequest.")
        XCTAssertEqual(req.metadata, req.queueOfTextMessages.metadata, "The metadata of QueueOfEditMessage shouold be equal to metadata EditMessageRequest.")
        XCTAssertEqual(req.repliedTo, req.queueOfTextMessages.repliedTo, "The repliedTo of QueueOfEditMessage shouold be equal to repliedTo EditMessageRequest.")
        XCTAssertEqual(req.textMessage, req.queueOfTextMessages.textMessage, "The textMessage of QueueOfEditMessage shouold be equal to textMessage EditMessageRequest.")
        XCTAssertEqual(req.threadId, req.queueOfTextMessages.threadId, "The threadId of QueueOfEditMessage shouold be equal to threadId EditMessageRequest.")
        XCTAssertEqual(req.typeCodeIndex, 0, "The typeCode of QueueOfEditMessage shouold be equal to typeCode EditMessageRequest.")
        XCTAssertEqual(req.uniqueId, req.queueOfTextMessages.uniqueId, "The uniqueId of QueueOfEditMessage shouold be equal to uniqueId EditMessageRequest.")
        XCTAssertEqual(req._messageType?.rawValue, req.messageType.rawValue, "The _messageType of QueueOfEditMessage shouold be equal to _messageType EditMessageRequest.")

        let req1 = EditMessageRequest(threadId: 1, messageType: .unknown, messageId: 1, textMessage: "TEST")
        XCTAssertEqual(req1.messageType, req1.queueOfTextMessages.messageType, "The uniqueId of QueueOfEditMessage shouold be equal to uniqueId EditMessageRequest.")
    }

    func test_whenSendTextMessageRequestToQueueOfImageMessages_itHasSameFields() {
        let textMessageRequest = SendTextMessageRequest(threadId: 1, textMessage: "TEST", messageType: .text)
        let imageRequest = UploadImageRequest(data: "TEST".data ?? Data(), mimeType: "jpg")
        let req = QueueOfFileMessages(req: textMessageRequest, imageRequest: imageRequest)

        XCTAssertEqual(req.xC, imageRequest.xC, "The xC field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.yC, imageRequest.yC, "The yC field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.hC, imageRequest.hC, "The hC field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.wC, imageRequest.wC, "The wC field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.messageType, textMessageRequest.messageType, "The messageType field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.metadata, textMessageRequest.metadata, "The metadata field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.mimeType, imageRequest.mimeType, "The mimeType field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.originalName, imageRequest.originalName, "The originalName field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.repliedTo, textMessageRequest.repliedTo, "The repliedTo field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.textMessage, textMessageRequest.textMessage, "The textMessage field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.threadId, textMessageRequest.threadId, "The threadId field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.typeCode, "0", "The typeCode field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.uniqueId, textMessageRequest.uniqueId, "The uniqueId field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.userGroupHash, imageRequest.userGroupHash, "The userGroupHash field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.imageToSend?.count, imageRequest.dataToSend?.count, "The dataToSend field of the QueueOfFileMessages should be equal")
    }

    func test_whenConvertUploadImageRequestToQueueOfFileMessages_itHasSameFields() {
        let req = UploadImageRequest(data: Data(), mimeType: "jpg")
        XCTAssertEqual(req.dataToSend?.count, req.queueOfFileMessages.imageToSend?.count, "The dataToSend count of the UploadImageRequest should be equal to imageToSend in QueueOfFileMessages.")
    }

    func test_whenTextMessageRequestIsNil_messageTypeIsUnknown() {
        let req = QueueOfFileMessages(req: nil, uploadFile: .init(data: Data()))
        XCTAssertEqual(req.messageType, .unknown, "The message type should be equal to unknown")
    }

    func test_whenSendTextMessageRequestToQueueOfFileMessages_itHasSameFields() {
        let textMessageRequest = SendTextMessageRequest(threadId: 1, textMessage: "TEST", messageType: .text)
        let fileRequest = UploadFileRequest(data: "TEST".data ?? Data(), mimeType: "jpg", originalName: "TEST", userGroupHash: "TEST")
        let req = QueueOfFileMessages(req: textMessageRequest, uploadFile: fileRequest)
        XCTAssertEqual(req.messageType, textMessageRequest.messageType, "The uniqueIds field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.metadata, textMessageRequest.metadata, "The uniqueIds field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.mimeType, fileRequest.mimeType, "The mimeType field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.originalName, fileRequest.originalName, "The originalName field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.repliedTo, textMessageRequest.repliedTo, "The repliedTo field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.textMessage, textMessageRequest.textMessage, "The textMessage field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.threadId, textMessageRequest.threadId, "The threadId field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.typeCode, "0", "The typeCode field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.uniqueId, textMessageRequest.uniqueId, "The uniqueId field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.userGroupHash, fileRequest.userGroupHash, "The userGroupHash field of the QueueOfFileMessages should be equal")
        XCTAssertEqual(req.fileToSend?.count, fileRequest.dataToSend?.count, "The fileToSend field of the QueueOfFileMessages should be equal")
    }

    func test_whenForwardMessageRequestToQueueOfForwardMessages_itHasSameFields() {
        var forwardRequest = ForwardMessageRequest(fromThreadId: 1, threadId: 1, messageIds: [1, 2, 3])
        forwardRequest.typeCodeIndex = 0
        let req = QueueOfForwardMessages(forward: forwardRequest)
        XCTAssertEqual(req.fromThreadId, forwardRequest.fromThreadId, "The fromThreadId field of the QueueOfForwardMessages should be equal")
        XCTAssertEqual(req.messageIds, forwardRequest.messageIds, "The messageIds field of the QueueOfForwardMessages should be equal")
        XCTAssertEqual(req.threadId, forwardRequest.threadId, "The threadId field of the QueueOfForwardMessages should be equal")
        XCTAssertEqual(req.typeCode, "0", "The typeCode field of the QueueOfForwardMessages should be equal")
        XCTAssertEqual(req.uniqueIds, forwardRequest.uniqueIds, "The uniqueIds field of the QueueOfForwardMessages should be equal")
    }

    func test_whenConvertForwardMessageRequestToQueueOfForwardMessages_itHasSameFields() {
        let req = ForwardMessageRequest(fromThreadId: 1, threadId: 1, messageIds: [1, 2, 3])
        XCTAssertEqual(req.fromThreadId, req.queueOfForwardMessages.fromThreadId, "The fromThreadId field of the QueueOfForwardMessages should be equal to fromThreadId filed of ForwardMessageRequest.")
        XCTAssertEqual(req.messageIds, req.queueOfForwardMessages.messageIds, "The messageIds field of the QueueOfForwardMessages should be equal to messageIds filed of ForwardMessageRequest.")
        XCTAssertEqual(req.threadId, req.queueOfForwardMessages.threadId, "The threadId field of the QueueOfForwardMessages should be equal to threadId filed of ForwardMessageRequest.")
        XCTAssertEqual(req.typeCodeIndex, 0, "The typeCode field of the QueueOfForwardMessages should be equal to typeCode filed of ForwardMessageRequest.")
        XCTAssertEqual(req.uniqueIds, req.queueOfForwardMessages.uniqueIds, "The uniqueIds field of the QueueOfForwardMessages should be equal to uniqueIds filed of ForwardMessageRequest.")
    }

    func test_whenSendTextMessageRequestToQueueOfTextMessages_itHasSameFields() {
        var textMessageRequest = SendTextMessageRequest(threadId: 1, textMessage: "TEST", messageType: .text)
        textMessageRequest.typeCodeIndex = 0
        let req = QueueOfTextMessages(textRequest: textMessageRequest)
        XCTAssertEqual(req.messageType, textMessageRequest.messageType, "The messageType field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.metadata, textMessageRequest.metadata, "The metadata field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.repliedTo, textMessageRequest.repliedTo, "The repliedTo field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.systemMetadata, textMessageRequest.systemMetadata, "The systemMetadata field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.textMessage, textMessageRequest.textMessage, "The textMessage field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.threadId, textMessageRequest.threadId, "The threadId field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.typeCode, "0", "The typeCode field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.uniqueId, textMessageRequest.uniqueId, "The uniqueId field of the QueueOfTextMessages should be equal")
    }

    func test_whenConvertSendTextMessageRequestToQueueOfTextMessages_itHasSameFields() {
        var textMessageRequest = SendTextMessageRequest(threadId: 1, textMessage: "TEST", messageType: .text)
        textMessageRequest.typeCodeIndex = 0
        let req = textMessageRequest.queueOfTextMessages
        XCTAssertEqual(req.messageType, textMessageRequest.messageType, "The messageType field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.metadata, textMessageRequest.metadata, "The metadata field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.repliedTo, textMessageRequest.repliedTo, "The repliedTo field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.systemMetadata, textMessageRequest.systemMetadata, "The systemMetadata field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.textMessage, textMessageRequest.textMessage, "The textMessage field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.threadId, textMessageRequest.threadId, "The threadId field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.typeCode, "0", "The typeCode field of the QueueOfTextMessages should be equal")
        XCTAssertEqual(req.uniqueId, textMessageRequest.uniqueId, "The uniqueId field of the QueueOfTextMessages should be equal")
    }

    func test_whenConvertADTOUniqueIdProtocolToChatCoreUniqueIdProtocol_bothAreEqual() {
        let req = SendTextMessageRequest(threadId: 1, textMessage: "TEST", messageType: .text)
        XCTAssertEqual(req.uniqueId, req.chatUniqueId, "The request uniqueId should be equal to chatUniqueId")
    }

    func test_whenConvertPodspaceResponseHashCodeNilToFileMetaData_isNil(){
        let uploadResponse = UploadFileResponse(name: "mypdf", hash: nil)
        let res = PodspaceFileUploadResponse(status: 200, path: "TEST", error: "TEST", message: "TETS", result: uploadResponse, timestamp: "TEST", reference: "TEST")
        let fileMetsData = res.toMetaData(mockConfig)
        XCTAssertNil(fileMetsData, "FileMetadata should be nil when hash is nil")
    }

    func test_whenConvertPodspaceResponseImageToFileMetaData_fieldsAreSetted(){
        let uploader = FileOwner(username: "j.john", name: "John", ssoId: 0, avatar: "https://www.test.com/mypicture.jpg", roles: [Roles.ownership.rawValue])
        let uploadResponse = UploadFileResponse(name: "mypicture", hash: "XYZ", parentHash: "YPZ", created: Date().millisecondsSince1970, updated: Date().millisecondsSince1970, extension: "jpg", size: 128, type: "image", actualHeight: 128, actualWidth: 128, owner: uploader, uploader: uploader)
        let res = PodspaceFileUploadResponse(status: 200, path: "TEST", error: "TEST", message: "TETS", result: uploadResponse, timestamp: "TEST", reference: "TEST")
        let fileMetsData = res.toMetaData(mockConfig, width: 128, height: 128)
        let path = Routes.images.rawValue
        let link = "\(mockConfig.fileServer)\(path)/\(res.result?.hash ?? "")"

        XCTAssertEqual(fileMetsData?.file?.extension, res.result?.extension , "The fileExtension field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.link, link, "The link field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.mimeType, res.result?.type , "The mimeType field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.name, res.result?.name , "The name field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.originalName, res.result?.name , "The originalName field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.size, res.result?.size , "The size field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.fileHash, res.result?.hash , "The fileHash field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.hashCode, res.result?.hash , "The hashCode field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.parentHash, res.result?.parentHash , "The parentHash field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.actualHeight, 128 , "The actualHeight field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.actualWidth, 128 , "The actualWidth field of the PodspaceFileUploadResponse should be equal")
    }


    func test_whenConvertPodspaceResponseFileToFileMetaData_fieldsAreSetted(){
        let uploader = FileOwner(username: "j.john", name: "John", ssoId: 0, avatar: "https://www.test.com/mypicture.jpg", roles: [Roles.ownership.rawValue])
        let uploadResponse = UploadFileResponse(name: "mypdf", hash: "XYZ", parentHash: "YPZ", created: Date().millisecondsSince1970, updated: Date().millisecondsSince1970, extension: "pdf", size: 128, type: "application/pdf", owner: uploader, uploader: uploader)
        let res = PodspaceFileUploadResponse(status: 200, path: "TEST", error: "TEST", message: "TETS", result: uploadResponse, timestamp: "TEST", reference: "TEST")
        let fileMetsData = res.toMetaData(mockConfig)
        let path = Routes.files.rawValue
        let link = "\(mockConfig.fileServer)\(path)/\(res.result?.hash ?? "")"

        XCTAssertEqual(fileMetsData?.file?.extension, res.result?.extension , "The fileExtension field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.link, link, "The link field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.mimeType, res.result?.type , "The mimeType field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.name, res.result?.name , "The name field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.originalName, res.result?.name , "The originalName field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.size, res.result?.size , "The size field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.fileHash, res.result?.hash , "The fileHash field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.hashCode, res.result?.hash , "The hashCode field of the PodspaceFileUploadResponse should be equal")
        XCTAssertEqual(fileMetsData?.file?.parentHash, res.result?.parentHash , "The parentHash field of the PodspaceFileUploadResponse should be equal")
        XCTAssertNil(fileMetsData?.file?.actualHeight, "The actualHeight field of the PodspaceFileUploadResponse should be equal")
        XCTAssertNil(fileMetsData?.file?.actualWidth, "The actualWidth field of the PodspaceFileUploadResponse should be equal")
    }

    func test_whenConvertHashAndHeadersToFile_hasSameFields() {
        let file = File(hashCode: "TEST", headers: ["Content-Disposition": "myfile","Content-Type": "pdf", "Content-Length": "500"])
        XCTAssertEqual(file.hashCode, "TEST", "The hashCode of File should be equal to TEST")
        XCTAssertEqual(file.name, "myfile.pdf", "The name of File should be equal to myfile")
        XCTAssertEqual(file.type, "pdf", "The type of File should be equal to pdf")
        XCTAssertEqual(file.size, 500, "The type of File should be equal to 500")
    }

    func test_whenConvertHashAndHeadersToFileWithNilValues_hasSameFields() {
        let file = File(hashCode: "TEST", headers: [:])
        XCTAssertEqual(file.hashCode, "TEST", "The hashCode of File should be equal to TEST")
        XCTAssertEqual(file.name, "default.none", "The name of File should be equal to default.none")
        XCTAssertNil(file.type, "The type of File should be equal to nil")
        XCTAssertEqual(file.size, 0, "The type of File should be equal to 0 when there is no key.")
    }


    func test_whenConvertGetHistoryRequestToGetHistoryRequest_hasSameFields() {
        let req = GetHistoryRequest(threadId: 1,
                                    count: 20,
                                    fromTime: UInt(Date().timeIntervalSince1970),
                                    messageId: 1,
                                    messageType: 0,
                                    offset: 100,
                                    order: "desc",
                                    query: "TEST",
                                    toTime: UInt(Date().timeIntervalSince1970),
                                    toTimeNanos: UInt(Date().timeIntervalSince1970),
                                    uniqueIds: ["1", "2"],
                                    hashtag: "TEST")
        XCTAssertEqual(req.threadId, req.fetchRequest.threadId, "The value of threadId in fetchRequest should be equal.")
        XCTAssertEqual(req.count, req.fetchRequest.count, "The value of count in fetchRequest should be equal.")
        XCTAssertEqual(req.fromTime, req.fetchRequest.fromTime, "The value of fromTime in fetchRequest should be equal.")
        XCTAssertEqual(req.messageId, req.fetchRequest.messageId, "The value of messageId in fetchRequest should be equal.")
        XCTAssertEqual(req.messageType, req.fetchRequest.messageType, "The value of messageType in fetchRequest should be equal.")
        XCTAssertEqual(req.offset, req.fetchRequest.offset, "The value of offset in fetchRequest should be equal.")
        XCTAssertEqual(req.order, req.fetchRequest.order, "The value of order in fetchRequest should be equal.")
        XCTAssertEqual(req.query, req.fetchRequest.query, "The value of query in fetchRequest should be equal.")
        XCTAssertEqual(req.toTime, req.fetchRequest.toTime, "The value of toTime in fetchRequest should be equal.")
        XCTAssertEqual(req.toTimeNanos, req.fetchRequest.toTimeNanos, "The value of toTimeNanos in fetchRequest should be equal.")
        XCTAssertEqual(req.uniqueIds, req.fetchRequest.uniqueIds, "The value of uniqueIds in fetchRequest should be equal.")
        XCTAssertEqual(req.hashtag, req.fetchRequest.hashtag, "The value of hashtag in fetchRequest should be equal.")
    }

    func test_whenConvertImageRequestWithInit_fieldsAreSet() {
        let req = ImageRequest(request: .init(hashCode: "TEST"), forceToDownloadFromServer: true)
        XCTAssertTrue(req.forceToDownloadFromServer, "forceToDownloadFromServer should be true")
        XCTAssertEqual(req.hashCode, "TEST", "hashCode should be equal to TEST")
    }

    func test_whenConvertFileRequestWithInit_fieldsAreSet() {
        let req = FileRequest(request: .init(hashCode: "TEST"), forceToDownloadFromServer: true)
        XCTAssertTrue(req.forceToDownloadFromServer, "forceToDownloadFromServer should be true")
        XCTAssertEqual(req.hashCode, "TEST", "hashCode should be equal to TEST")
    }

    func test_whenConvertUploadFileRequestWithInit_fieldsAreSet() {
        let req = UploadFileRequest(request: .init(request: .init(data: "TEST".data!), userGroupHash: "TEST"), userGroupHash: "TEST")
        XCTAssertEqual(req.userGroupHash, "TEST", "userGroupHash should be equal to TEST")
        XCTAssertEqual(req.dataToSend?.count, "TEST".data?.count, "dataToSend should be equal to data")
    }

    func test_whenGetRequestTypeEnum_hasValue() {
        let req = AddRemoveParticipant(participnats: [.init()], requestType: ChatMessageVOTypes.joinThread.rawValue)
        XCTAssertEqual(req.requestTypeEnum, .joinThread, "requestTypeEnum should have value and be equal to joinThread")
    }

    func test_whenGetRequestTypeEnumWhenHasUnknownValue_hasNilValue() {
        let req = AddRemoveParticipant(participnats: [.init()], requestType: 100000000)
        XCTAssertNil(req.requestTypeEnum, "requestTypeEnum should have value and be nil.")
    }

    func test_whenGetRequestTypeEnumWhenHasUnknownValue_hasUnknownCase() {
        let req = AddRemoveParticipant(participnats: [.init()], requestType: nil)
        XCTAssertEqual(req.requestTypeEnum, .unknown, "requestTypeEnum should have value and be equal to unknown.")
    }

    func test_whenMetadataOfAMessageIsAddOrRemoveParticipant_canDecode() {
        let jsonJoin = "{\"participantVOS\":[],\"requestType\":39,\"requestTime\": \(UInt(Date().timeIntervalSince1970))}"
        let messageJoin = Message(messageType: .participantJoin, metadata: jsonJoin)
        XCTAssertNotNil(messageJoin.addRemoveParticipant, "addRemoveParticipant should not be nil")
        XCTAssertEqual(messageJoin.addRemoveParticipant?.requestTypeEnum, .joinThread, "addRemoveParticipant requestTypeEnum should not be equal to joinThread")


        let jsonLeave = "{\"participantVOS\":[],\"requestType\":9,\"requestTime\": \(UInt(Date().timeIntervalSince1970))}"
        let messageLeft = Message(messageType: .participantLeft, metadata: jsonLeave)
        XCTAssertNotNil(messageLeft.addRemoveParticipant, "addRemoveParticipant should not be nil")
        XCTAssertEqual(messageLeft.addRemoveParticipant?.requestTypeEnum, .leaveThread, "addRemoveParticipant requestTypeEnum should not be equal to joinThread")
    }

    func test_whenMetadataOfAMessageIsInvalid_returnNil() {
        let jsonJoin = "INVALID_DATA"
        let messageJoin = Message(messageType: .participantJoin, metadata: jsonJoin)
        XCTAssertNil(messageJoin.addRemoveParticipant, "addRemoveParticipant should be nil")
    }

    var mockConfig: ChatConfig {
       return .init(asyncConfig: try! .init(socketAddress: "wss://tett.com", peerName: "TEST"), callConfig: .init(), token: "TEST", ssoHost: "TEST", platformHost: "TEST", fileServer: "TEST")
    }
}
