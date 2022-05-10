//
//  CMTagParticipant.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/23/21.

import Foundation
import CoreData


extension CMTagParticipant {
    
    @NSManaged public var id                    : NSNumber?
    @NSManaged public var active                : NSNumber?
    @NSManaged public var tagId                 : NSNumber?
    @NSManaged public var threadId              : NSNumber?
    @NSManaged public var conversation          : CMConversation?
    
}
