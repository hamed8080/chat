//
//  CMAssistant.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMAssistant {
    @NSManaged public var inviteeId   : NSNumber? //inviteeId == participant.Id
    @NSManaged public var contactType : String?
    @NSManaged public var assistant   : NSData?
    @NSManaged public var participant : CMParticipant?
    @NSManaged public var roles       : [String]?
    @NSManaged public var block       : NSNumber
}
