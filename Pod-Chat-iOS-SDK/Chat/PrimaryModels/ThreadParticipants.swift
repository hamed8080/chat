//
//  ThreadParticipants.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

//#######################################################################################
//#############################      ThreadParticipants        (reformatThreadParticipants)
//#######################################################################################

open class ThreadParticipants {
    
    public var returnData: [Participant] = []
    
    public init(participantsContent: [JSON]) {
        for item in participantsContent {
            let temp = Participant(messageContent: item, threadId: nil)
            self.returnData.append(temp)
        }
    }
    
    public init(theParticipants: [Participant]?) {
        
        if let participants = theParticipants {
            for item in participants {
                self.returnData.append(item)
            }
        }
    }
    
    public init(theThreadParticipants: ThreadParticipants) {
        self.returnData = theThreadParticipants.returnData
    }
    
    public func reformatThreadParticipants() -> ThreadParticipants {
        return self
    }
    
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
