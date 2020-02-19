//
//  ContactEventModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/3/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class ContactEventModel {
    
    public let type:                        ContactEventTypes
    public let contacts:                    [Contact]?
    public let contactsLastSeenDuration:    [UserLastSeenDuration]?
    
    init(type: ContactEventTypes, contacts: [Contact]?, contactsLastSeenDuration: [UserLastSeenDuration]?) {
        self.type                       = type
        self.contacts                   = contacts
        self.contactsLastSeenDuration   = contactsLastSeenDuration
    }
    
}
