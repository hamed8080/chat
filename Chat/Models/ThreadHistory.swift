//
//  ThreadHistory.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

//#######################################################################################
//#############################      ThreadHistory        (reformatThreadHistory)
//#######################################################################################

open class ThreadHistory {
    
    public var returnData: [Message] = []
    
    init(threadId: Int, historyContent: [JSON]) {
        for item in historyContent {
            let temp = Message(threadId: threadId, pushMessageVO: item)
            self.returnData.append(temp)
        }
    }
    
    func reformatThreadHistory() -> ThreadHistory {
        return self
    }
    
    func formatToJSON() -> [JSON] {
        var messageJSON: [JSON] = []
        for item in returnData {
            let json = item.formatToJSON()
            messageJSON.append(json)
        }
        //        let result: JSON = ["history":        messageJSON]
        return messageJSON
    }
    
}
