//
//  ChatResponse.swift
//  FanapPodChatSDK
//
//  Created by hamed on 7/20/22.
//

import Foundation

public struct ChatResponse{
    public var uniqueId        : String? = nil
    public var result          : Any?
    public var cacheResponse   : Any?
    public var error           : ChatError?
    public var contentCount    : Int = 0
}
