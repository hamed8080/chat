//
// BotManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

final class BotManager: BotProtocol {
    let chat: ChatInternalProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func add(_ request: AddBotCommandRequest) {
        chat.prepareToSendAsync(req: request, type: .defineBotCommand)
    }

    func onAddBotCommand(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<BotInfo> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .bot(.addCommand(response)))
    }

    func get(_ request: GetUserBotsRequest) {
        chat.prepareToSendAsync(req: request, type: .getUserBots)
    }

    func onBots(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[BotInfo]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .bot(.bots(response)))
    }

    func onBotMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<String?> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .bot(.message(response)))
    }

    func create(_ request: CreateBotRequest) {
        chat.prepareToSendAsync(req: request, type: .createBot)
    }

    func onCreateBot(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<BotInfo> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .bot(.create(response)))
    }

    func remove(_ request: RemoveBotCommandRequest) {
        chat.prepareToSendAsync(req: request, type: .removeBotCommands)
    }

    func onRemoveBotCommand(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<BotInfo> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .bot(.removeCommand(response)))
    }

    func start(_ request: StartStopBotRequest) {
        chat.prepareToSendAsync(req: request, type: .startBot)
    }

    func stop(_ request: StartStopBotRequest) {
        chat.prepareToSendAsync(req: request, type: .stopBot)
    }

    func onStartStopBot(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<String> = asyncMessage.toChatResponse()
        let start = asyncMessage.chatMessage?.type == .startBot
        chat.delegate?.chatEvent(event: .bot( start ? .start(response) : .stop(response)))
    }
}
