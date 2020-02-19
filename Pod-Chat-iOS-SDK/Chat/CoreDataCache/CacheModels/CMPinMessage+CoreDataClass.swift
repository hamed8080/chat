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
    
    public func convertCMPinMessageToPinUnpinMessageObject() -> PinUnpinMessage {
            
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
                                                      text:         self.text)
                return pinMessageModel
            }
            
            createVariables()
            let model = createPinMessageModel()
            
            return model
            
        }
    
}
