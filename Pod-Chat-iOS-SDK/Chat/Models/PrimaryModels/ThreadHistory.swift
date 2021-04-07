//
//  ThreadHistory.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class ThreadHistory {
    
    public var returnData: [Message] = []
    
    public init(threadId: Int, historyContent: [JSON]) {
        for item in historyContent {
            let temp = Message(threadId: threadId, pushMessageVO: item)
            self.returnData.append(temp)
        }
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(historyContent: [Message]) {
        
        for item in historyContent {
            let temp = item
            self.returnData.append(temp)
        }
        
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(theThreadHistory: ThreadHistory) {
        
        self.returnData = theThreadHistory.returnData
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public func reformatThreadHistory() -> ThreadHistory {
        return self
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public func formatToJSON() -> [JSON] {
        var messageJSON: [JSON] = []
        for item in returnData {
            let json = item.formatToJSON()
            messageJSON.append(json)
        }
        //        let result: JSON = ["history":        messageJSON]
        return messageJSON
    }
    
}
