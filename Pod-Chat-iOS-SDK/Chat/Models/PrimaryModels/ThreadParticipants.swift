//
//  ThreadParticipants.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class ThreadParticipants {
    
    public var returnData: [Participant] = []
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(participantsContent: [JSON]) {
        for item in participantsContent {
            let temp = Participant(messageContent: item, threadId: nil)
            self.returnData.append(temp)
        }
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(theParticipants: [Participant]?) {
        
        if let participants = theParticipants {
            for item in participants {
                self.returnData.append(item)
            }
        }
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(theThreadParticipants: ThreadParticipants) {
        self.returnData = theThreadParticipants.returnData
    }
    
    public func reformatThreadParticipants() -> ThreadParticipants {
        return self
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public func formatToJSON() -> [JSON] {
        var participantsJSON: [JSON] = []
        for item in returnData {
            let json = item.formatToJSON()
            participantsJSON.append(json)
        }
        //        let result: JSON = ["participants":        participantsJSON]
        return participantsJSON
    }
    
}
