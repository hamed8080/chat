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
    
    init(participantsContent: [JSON]) {
        for item in participantsContent {
            let temp = Participant(messageContent: item)
            self.returnData.append(temp)
        }
    }
    
    func reformatThreadParticipants() -> ThreadParticipants {
        return self
    }
    
    func formatToJSON() -> [JSON] {
        var participantsJSON: [JSON] = []
        for item in returnData {
            let json = item.formatToJSON()
            participantsJSON.append(json)
        }
        //        let result: JSON = ["participants":        participantsJSON]
        return participantsJSON
    }
    
}
