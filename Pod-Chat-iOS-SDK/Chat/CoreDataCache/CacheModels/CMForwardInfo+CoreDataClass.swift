//
//  CMForwardInfo+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMForwardInfo: NSManagedObject {
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func convertCMObjectToObject() -> ForwardInfo {
        
        let forwardInfoModel = ForwardInfo(conversation: conversation?.convertCMObjectToObject(showInviter: false, showLastMessageVO: false, showParticipants: false, showPinMessage: false),
                                           participant: participant?.convertCMObjectToObject())
        
        return forwardInfoModel
    }
    
}
