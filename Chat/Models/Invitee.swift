//
//  Invitee.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      Invitee        (formatDataToMakeInvitee)
//#######################################################################################

class Invitee {
    /*
     * + InviteeVO       {object}
     *    - id           {string}
     *    - idType       {int}
     */
    
    let id:     String?
    var idType: Int = 0
    
    init(messageContent: JSON) {
        self.id =       messageContent["id"].string
        if let myIdType = messageContent["idType"].string {
            let type = myIdType
            if (type == "TO_BE_USER_SSO_ID") {
                self.idType = 1
            } else if (type == "TO_BE_USER_CONTACT_ID") {
                self.idType = 2
            } else if (type == "TO_BE_USER_CELLPHONE_NUMBER") {
                self.idType = 3
            } else if (type == "TO_BE_USER_USERNAME") {
                self.idType = 4
            }
        }
    }
    
    func formatDataToMakeInvitee() -> Invitee {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "idType":           idType]
        return result
    }
    
}
