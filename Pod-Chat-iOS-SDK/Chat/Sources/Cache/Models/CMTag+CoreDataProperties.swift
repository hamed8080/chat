//
//  CMTag.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/23/21.

import Foundation
import CoreData


extension CMTag {
    
    @NSManaged public var id                    : NSNumber?
    @NSManaged public var name                  : String
    @NSManaged public var owner                 : CMParticipant
    @NSManaged public var active                : NSNumber
    @NSManaged public var tagParticipants       : Set<CMTagParticipant>?
}
