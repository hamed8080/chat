//
//  MessageType.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 1/31/21.
//
import Foundation

public enum MessageType: Int, Codable, SafeDecodable {
    case TEXT = 1
    case VOICE = 2
    case PICTURE = 3
    case VIDEO = 4
    case SOUND = 5
    case FILE = 6
    case POD_SPACE_PICTURE = 7
    case POD_SPACE_VIDEO = 8
    case POD_SPACE_SOUND = 9
    case POD_SPACE_VOICE = 10
    case POD_SPACE_FILE = 11
    case LINK = 12
    case END_CALL = 13
    case START_CALL = 14
    case STICKER = 15
    case LOCATION = 16

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case UNKNOWN
}
