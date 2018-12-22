//
//  CMReplyInfo+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMReplyInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMReplyInfo> {
        return NSFetchRequest<CMReplyInfo>(entityName: "CMReplyInfo")
    }

    @NSManaged public var deletedd: NSNumber?
    @NSManaged public var message: String?
    @NSManaged public var messageType: NSNumber?
    @NSManaged public var metadata: String?
    @NSManaged public var repliedToMessageId: NSNumber?
    @NSManaged public var systemMetadata: String?
    @NSManaged public var participant: CMParticipant?

}
