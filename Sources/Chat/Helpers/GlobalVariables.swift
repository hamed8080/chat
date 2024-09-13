//
// GlobalVariables.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public typealias CompletionTypeWithoutUniqueId<T> = (T?, ChatError?) -> Void
public typealias CompletionType<T: Decodable> = (ChatResponse<T>) -> Void
public typealias CompletionTypeNoneDecodeable<T> = (ChatResponse<T>) -> Void
public typealias CacheResponseType<T> = (ChatResponse<T>) -> Void
public typealias UniqueIdResultType = (String) -> Void
public typealias UniqueIdsResultType = ([String]) -> Void
public typealias OnSentType = (ChatResponse<MessageResponse>) -> Void
public typealias OnDeliveryType = (ChatResponse<MessageResponse>) -> Void
public typealias OnSeenType = (ChatResponse<MessageResponse>) -> Void
