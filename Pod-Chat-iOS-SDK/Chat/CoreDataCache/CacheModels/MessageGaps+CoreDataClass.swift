//
//  MessageGaps+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MessageGaps)
public class MessageGaps: NSManagedObject {
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    func updateObject(onThreadId threadId: Int, withMessageId messageId: Int, withPreviousId previousId: Int) {
        self.previousId = previousId as NSNumber?
        self.messageId  = messageId as NSNumber?
        self.threadId   = threadId  as NSNumber?
    }
    
}
