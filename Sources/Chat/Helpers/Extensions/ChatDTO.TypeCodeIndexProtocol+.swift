//
//  ChatDTO.TypeCodeIndexProtocol+.swift
//  Chat
//
//  Created by hamed on 3/1/23.
//

import ChatDTO

public extension ChatDTO.TypeCodeIndexProtocol {
    func toTypeCode(_ chat: Chat) -> String? {
        chat.config.typeCodes[typeCodeIndex].typeCode
    }
}
