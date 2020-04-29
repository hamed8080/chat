//
//  BotManagementMethods.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/5/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON

// MARK: - Public Methods
// MARK: - Bot Management

extension Chat {
    
    // MARK: - Create Bot
    /// CreateBot:
    /// it will create a bot
    ///
    /// By calling this function, HTTP request of type (CREATE_BOT) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "CreateBotRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameters:
    ///     - inputModel:   (input) you have to send your parameters insid this model. (AddContactRequest)
    ///     - uniqueId:     (response) it will returns the request 'UniqueId' that will send to server. (String)
    ///     - completion:   (response) it will returns the response that comes from server to this request. (Any as! CreateBotResponse)
    public func createBot(inputModel createBotInput:  CreateBotRequest,
                          uniqueId:                 @escaping (String) -> (),
                          completion:               @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to create bot with this parameters: \n \(createBotInput.botName)", context: "Chat")
        uniqueId(createBotInput.uniqueId)
        
        createBotCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.CREATE_BOT.intValue(),
                                            content:            createBotInput.botName,
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           createBotInput.typeCode ?? generalTypeCode,
                                            uniqueId:           createBotInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(CreateBotCallback(), createBotInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    // MARK: - Add Bot Commands
    /// AddBotCommand:
    /// it will add a bot command
    ///
    /// By calling this function, HTTP request of type (CONFIG_BOT_COMMAND) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "AddBotCommandRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameters:
    ///     - inputModel:   (input) you have to send your parameters insid this model. (AddBotCommandRequest)
    ///     - uniqueId:     (response) it will returns the request 'UniqueId' that will send to server. (String)
    ///     - completion:   (response) it will returns the response that comes from server to this request. (Any as! AddBotCommandResponse)
    public func addBotCommand(inputModel addBotCommandsInput:    AddBotCommandRequest,
                              uniqueId:         @escaping (String) -> (),
                              completion:       @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to add bot command with this parameters: \n \(addBotCommandsInput.botName)", context: "Chat")
        uniqueId(addBotCommandsInput.uniqueId)
        
        addBotCommandCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.DEFINE_BOT_COMMAND.intValue(),
                                            content:            "\(addBotCommandsInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           addBotCommandsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           addBotCommandsInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(AddBotCommandCallback(), addBotCommandsInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    // MARK: - Start Bot
    /// StartBot:
    /// it will stat a bot on a thread
    ///
    /// By calling this function, HTTP request of type (START_BOT) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "StartStopBotRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameters:
    ///     - inputModel:   (input) you have to send your parameters insid this model. (StartStopBotRequest)
    ///     - uniqueId:     (response) it will returns the request 'UniqueId' that will send to server. (String)
    ///     - completion:   (response) it will returns the response that comes from server to this request. (Any as! StartStopBotResponse)
    public func startBot(inputModel startBotInput:  StartStopBotRequest,
                         uniqueId:      @escaping (String) -> (),
                         completion:    @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to start bot with this parameters: \n botName = \(startBotInput.botName) \n threadId = \(startBotInput.threadId)", context: "Chat")
        uniqueId(startBotInput.uniqueId)
        
        startBotCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.START_BOT.intValue(),
                                            content:            "\(startBotInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          startBotInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           startBotInput.typeCode ?? generalTypeCode,
                                            uniqueId:           startBotInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(StartBotCallback(), startBotInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    // MARK: - Stop Bot
    /// StopBot:
    /// it will stop a bot on a thread
    ///
    /// By calling this function, HTTP request of type (STOP_BOT) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "StartStopBotRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameters:
    ///     - inputModel:   (input) you have to send your parameters insid this model. (StartStopBotRequest)
    ///     - uniqueId:     (response) it will returns the request 'UniqueId' that will send to server. (String)
    ///     - completion:   (response) it will returns the response that comes from server to this request. (Any as! StartStopBotResponse)
    public func stopBot(inputModel stopBotInput:    StartStopBotRequest,
                        uniqueId:       @escaping (String) -> (),
                        completion:     @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to stop bot with this parameters: \n botName = \(stopBotInput.botName) \n threadId = \(stopBotInput.threadId)", context: "Chat")
        uniqueId(stopBotInput.uniqueId)
        
        stopBotCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.STOP_BOT.intValue(),
                                            content:            "\(stopBotInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          stopBotInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           stopBotInput.typeCode ?? generalTypeCode,
                                            uniqueId:           stopBotInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(StopBotCallback(), stopBotInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
}
