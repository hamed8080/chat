import XCTest
import Logger
import Mocks
import Additive
import ChatCore
import ChatDTO
@testable import ChatExtensions

final class ChatExtensionsConformanceTests: XCTestCase {
    
    func test_conformToChatSendable() {
        let types: [ChatSendable.Type] = [AcceptCallRequest.self,
                                          AddBotCommandRequest.self,
                                          AddCallParticipantsRequest.self,
                                          AddParticipantRequest.self,
                                          AddTagParticipantsRequest.self,
                                           AllThreadsUnreadCountRequest.self,
                                          AssistantsHistoryRequest.self,
                                          AssistantsRequest.self,
                                          AuditorRequest.self,
                                          BatchDeleteMessageRequest.self,
                                          BlockRequest.self,
                                          BlockUnblockAssistantRequest.self,
                                          BlockedAssistantsRequest.self,
                                          BlockedListRequest.self,
                                          CallClientErrorRequest.self,
                                          CallStickerRequest.self,
                                          CallsHistoryRequest.self,
                                          CancelCallRequest.self,
                                          ChangeThreadTypeRequest.self,
                                          ContactsRequest.self,
                                          CreateCallThreadRequest.self,
                                          CreateTagRequest.self,
                                          CreateThreadRequest.self,
                                          CreateThreadWithMessage.self,
                                          DeactiveAssistantRequest.self,
                                          DeleteMessageRequest.self,
                                          DeleteTagRequest.self,
                                          EditTagRequest.self,
                                          GeneralSubjectIdRequest.self,
                                          GetHistoryRequest.self,
                                          GetJoinCallsRequest.self,
                                          GetTagParticipantsRequest.self,
                                          GetUserBotsRequest.self,
                                          IsThreadNamePublicRequest.self,
                                          LeaveThreadRequest.self,
                                          MentionRequest.self,
                                          MessageDeliveredUsersRequest.self,
                                          MessageSeenByUsersRequest.self,
                                          MuteCallRequest.self,
                                          MutualGroupsRequest.self,
                                          NotSeenDurationRequest.self,
                                          PinUnpinMessageRequest.self,
                                          RegisterAssistantsRequest.self,
                                          RemoveBotCommandRequest.self,
                                          RemoveCallParticipantsRequest.self,
                                          RemoveParticipantRequest.self,
                                          RemoveTagParticipantsRequest.self,
                                          RenewCallRequest.self,
                                          RolesRequest.self,
                                          SafeLeaveThreadRequest.self,
                                          RolesRequest.self,
                                          SafeLeaveThreadRequest.self,
                                          SendSignalMessageRequest.self,
                                          SendStatusPingRequest.self,
                                          StartCallRequest.self,
                                          StartStopBotRequest.self,
                                          ThreadParticipantRequest.self,
                                          ThreadsRequest.self,
                                          ThreadsUnreadCountRequest.self,
                                          UNMuteCallRequest.self,
                                          UnBlockRequest.self,
                                          UpdateChatProfile.self,
                                          UpdateThreadInfoRequest.self,
                                          UserInfoRequest.self]

        XCTAssertTrue(!types.isEmpty)
    }

    func test_conformToSubjectIdProtocol() {
        let types: [SubjectProtocol.Type] = [
            StartStopBotRequest.self,
            AcceptCallRequest.self,
            AddCallParticipantsRequest.self,
            CallClientErrorRequest.self,
            CallStickerRequest.self,
            CancelCallRequest.self,
            MuteCallRequest.self,
            RemoveCallParticipantsRequest.self,
            RenewCallRequest.self,
            UNMuteCallRequest.self,
            DeleteMessageRequest.self,
            EditMessageRequest.self,
            ForwardMessageRequest.self,
            GetHistoryRequest.self,
            MentionRequest.self,
            PinUnpinMessageRequest.self,
            ReplyMessageRequest.self,
            SendSignalMessageRequest.self,
            SendTextMessageRequest.self,
            AddParticipantRequest.self,
            AddTagParticipantsRequest.self,
            ChangeThreadTypeRequest.self,
            DeleteTagRequest.self,
            EditTagRequest.self,
            GeneralSubjectIdRequest.self,
            GetTagParticipantsRequest.self,
            LeaveThreadRequest.self,
            RemoveParticipantRequest.self,
            RemoveTagParticipantsRequest.self,
            SafeLeaveThreadRequest.self,
            ThreadParticipantRequest.self,
            UpdateThreadInfoRequest.self,
            AuditorRequest.self,
            RolesRequest.self
        ]
        XCTAssertTrue(!types.isEmpty)
    }

    func test_conformToPlainTextSendable() {
        let types: [PlainTextSendable.Type] = [
            CreateBotRequest.self,
            EditMessageRequest.self,
            ForwardMessageRequest.self,
            MessageDeliverRequest.self,
            MessageSeenRequest.self,
            ReplyMessageRequest.self,
            SendTextMessageRequest.self,
            JoinPublicThreadRequest.self
        ]
        XCTAssertTrue(!types.isEmpty)
    }

    func test_conformResponseToPaginatable() {
        let types: [Paginateable.Type] = [
            CallsHistoryRequest.self,
            GetJoinCallsRequest.self,
            BlockedListRequest.self,
            ContactsRequest.self,
            GetHistoryRequest.self,
            AssistantsHistoryRequest.self,
            AssistantsRequest.self,
            BlockedAssistantsRequest.self,
            MutualGroupsRequest.self,
            ThreadParticipantRequest.self,
            ThreadsRequest.self,
        ]
        XCTAssertTrue(!types.isEmpty)
    }

    func test_conformToMessageTypeProtocol() {
        let types: [MessageTypeProtocol.Type] = [
            EditMessageRequest.self,
            ReplyMessageRequest.self,
            SendTextMessageRequest.self
        ]
        XCTAssertTrue(!types.isEmpty)
    }

    func test_conformToReplyProtocol() {
        let types: [ReplyProtocol.Type] = [
            EditMessageRequest.self,
            ReplyMessageRequest.self,
            SendTextMessageRequest.self
        ]
        XCTAssertTrue(!types.isEmpty)
    }

    func test_conformToMetadataProtocol() {
        let types: [MetadataProtocol.Type] = [
            EditMessageRequest.self,
            ReplyMessageRequest.self,
            SendTextMessageRequest.self
        ]
        XCTAssertTrue(!types.isEmpty)
    }

    func test_conformToSystemtMetadataProtocol() {
        let types: [SystemtMetadataProtocol.Type] = [
            ReplyMessageRequest.self,
            SendTextMessageRequest.self
        ]
        XCTAssertTrue(!types.isEmpty)
    }

    func test_conformToQueueable() {
        let types: [Queueable.Type] = [
            ReplyMessageRequest.self,
            ForwardMessageRequest.self,
            EditMessageRequest.self,
            SendTextMessageRequest.self
        ]
        XCTAssertTrue(!types.isEmpty)
    }
}
