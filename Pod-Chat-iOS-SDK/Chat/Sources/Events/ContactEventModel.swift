//
//  ContactEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//


import Foundation


open class ContactEventModel {
    
    public let type:                        ContactEventTypes
    public let contacts:                    [Contact]?
    public let contactsLastSeenDuration:    [UserLastSeenDuration]?
    
    init(type: ContactEventTypes, contacts: [Contact]? = nil, contactsLastSeenDuration: [UserLastSeenDuration]? = nil) {
        self.type                       = type
        self.contacts                   = contacts
        self.contactsLastSeenDuration   = contactsLastSeenDuration
    }
    
}

public enum ContactEventTypes {
    case CONTACTS_LIST_CHANGE
    case CONTACTS_SEARCH_RESULT_CHANGE
    case CONTACTS_LAST_SEEN
}
