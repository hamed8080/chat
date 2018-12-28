//
//  CMMessageChangeState+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMMessageChangeState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMMessageChangeState> {
        return NSFetchRequest<CMMessageChangeState>(entityName: "CMMessageChangeState")
    }

    @NSManaged public var messageId:    NSNumber?
    @NSManaged public var senderId:     NSNumber?
    @NSManaged public var threadId:     NSNumber?

}
