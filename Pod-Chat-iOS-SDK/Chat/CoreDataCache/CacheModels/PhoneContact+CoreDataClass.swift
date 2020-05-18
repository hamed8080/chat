//
//  PhoneContact+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class PhoneContact: NSManagedObject {
    
    func updateObject(with contact: AddContactRequest) {
        self.cellphoneNumber    = contact.cellphoneNumber
        self.email              = contact.email
        self.firstName          = contact.firstName
        self.lastName           = contact.lastName
    }
    
}
