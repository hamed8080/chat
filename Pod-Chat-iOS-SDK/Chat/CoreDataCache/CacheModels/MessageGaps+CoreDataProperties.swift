//
//  MessageGaps+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/31/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension MessageGaps {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageGaps> {
        return NSFetchRequest<MessageGaps>(entityName: "MessageGaps")
    }

    @NSManaged public var messageId:    NSNumber?
    @NSManaged public var threadId:     NSNumber?
    @NSManaged public var previousId:   NSNumber?

}
