//
//  ResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/15/21.
//

import Foundation
import FanapPodAsyncSDK

protocol ResponseHandler {
    static func handle(_ chatMessage:NewChatMessage ,_ asyncMessage: NewAsyncMessage)
}
