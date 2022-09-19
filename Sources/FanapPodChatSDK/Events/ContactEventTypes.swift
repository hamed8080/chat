//
//  ContactEventTypes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//


import Foundation

public enum ContactEventTypes {
    case BLOCKED(BlockedContact, id:Int?)
    case CONTACTS_LAST_SEEN([UserLastSeenDuration])
}
