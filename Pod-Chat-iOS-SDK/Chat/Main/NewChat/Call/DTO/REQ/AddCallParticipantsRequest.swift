//
//  AddCallParticipantsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class AddCallParticipantsRequest:BaseRequest{
    
    let callId     : Int?
    var contactIds : [Int]?     = nil
    var userNames  : [Invitee]? = nil
    var coreuserIds: [Invitee]? = nil
    
    public init(callId: Int? = nil, typeCode:String? = nil, uniqueId:String? = nil) {
        self.callId     = callId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    public init(callId: Int? = nil, contactIds:[Int], typeCode:String? = nil, uniqueId:String? = nil) {
        self.callId       = callId
        self.contactIds   = contactIds
        
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    public init(callId: Int? = nil,userNames:[String], typeCode:String? = nil, uniqueId:String? = nil) {
        self.callId     = callId
        var invitess:[Invitee] = []
        userNames.forEach { userame in
            invitess.append(Invitee(id: userame, idType: .TO_BE_USER_USERNAME))
        }
        self.userNames  = invitess
        
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    public init(callId: Int? = nil,coreUserIds:[Int], typeCode:String? = nil, uniqueId:String? = nil) {
        self.callId     = callId
        var invitess:[Invitee] = []
        coreUserIds.forEach { coreuserId in
            invitess.append(Invitee(id: "\(coreuserId)", idType: .TO_BE_CORE_USER_ID))
        }
        self.coreuserIds  = invitess
        
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        if let contactids = contactIds , contactids.count > 0 {
            try? container.encode(contactids)
        }
        
        if let coreUserIds = contactIds{
            try? container.encode(coreUserIds)
        }
        
        if let userNames = userNames{
            try? container.encode(userNames)
        }
    }
    
}
