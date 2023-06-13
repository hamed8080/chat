//
// MapEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/3/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum MapEventTypes {
    case routes(ChatResponse<[Route]>)
    case search(ChatResponse<[MapItem]>)
    case reverse(ChatResponse<MapReverse>)
    case image(ChatResponse<Data>)
}
