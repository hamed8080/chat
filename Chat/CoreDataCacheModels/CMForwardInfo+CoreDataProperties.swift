//
//  CMForwardInfo+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMForwardInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMForwardInfo> {
        return NSFetchRequest<CMForwardInfo>(entityName: "CMForwardInfo")
    }

    @NSManaged public var conversation: CMConversation?
    @NSManaged public var participant:  CMParticipant?

}
