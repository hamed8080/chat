//
//  CMPinMessage+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/30/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMPinMessage: NSManagedObject {
    
	@available(*,deprecated , message:"Removed in XX.XX.XX version")
    public func convertCMObjectToObject() -> PinUnpinMessage {
            
        var messageId:  Int?
        var notifyAll:  Bool?
        
        func createVariables() {
            
            if let messageId_ = self.messageId as? Int {
                messageId = messageId_
            }
            if let notifyAll_ = self.notifyAll as? Bool {
                notifyAll = notifyAll_
            }
        }
        
        func createPinMessageModel() -> PinUnpinMessage {
            let pinMessageModel = PinUnpinMessage(messageId:    messageId ?? 0,
                                                  notifyAll:    notifyAll ?? false,
                                                  text:         self.text,
                                                  sender:       nil,
                                                  time:         nil)
            return pinMessageModel
        }
        
        createVariables()
        let model = createPinMessageModel()
        
        return model
        
    }
    
	@available(*,deprecated , message:"Removed in XX.XX.XX version")
    func updateObject(with pinMessage: PinUnpinMessage) {
        if let messageId = pinMessage.messageId as NSNumber? {
            self.messageId = messageId
        }
        if let notifyAll = pinMessage.notifyAll as NSNumber? {
            self.notifyAll = notifyAll
        }
        if let text = pinMessage.text {
            self.text = text
        }
    }
    
    
}
