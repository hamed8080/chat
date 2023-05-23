//
// ChatImplementation+DeleteTag.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension ChatImplementation {
    /// Delete a tag.
    /// - Parameters:
    ///   - request: The id of tag.
    ///   - completion: Response of the request if tag deleted successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deleteTag(_ request: DeleteTagRequest, completion: @escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .deleteTag, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onDeleteTag(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Tag> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .tag(.deleteTag(response)))
        cache?.tag?.delete(response.result?.id)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
