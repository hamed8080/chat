//
//  CMMutualGroup+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 1/30/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMMutualGroup : NSManagedObject {

    @NSManaged public var mutualId:String?
    @NSManaged public var idType:NSNumber?
    @NSManaged public var conversation : CMConversation?
}
