//
//  CMPinMessage+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMPinMessage{
    
    public static let crud = CoreDataCrud<CMPinMessage>(entityName: "CMPinMessage")
    
    public func getCodable() -> PinUnpinMessage?{
		guard let messageId = messageId as? Int , let notifyAll = notifyAll as? Bool else {return nil}
		return PinUnpinMessage(messageId: messageId,
							   notifyAll: notifyAll,
							   text: text,
							   sender: nil,
							   time: nil)
    }
    
    public class func convertPinMessageToCM(pinMessage:PinUnpinMessage  ,entity:CMPinMessage? = nil) -> CMPinMessage{
        let model      = entity ?? CMPinMessage()
        model.messageId = pinMessage.messageId as NSNumber?
		model.notifyAll = pinMessage.notifyAll as NSNumber
		model.text     = pinMessage.text
        return model
    }
    
    public class func insertOrUpdate(pinMessage:PinUnpinMessage , resultEntity:((CMPinMessage)->())? = nil){
        
		if let findedEntity = CMPinMessage.crud.find(keyWithFromat: "messageId == %i", value: pinMessage.messageId){
            let cmPinMessage = convertPinMessageToCM(pinMessage: pinMessage, entity: findedEntity)
            resultEntity?(cmPinMessage)
        }else{
            CMPinMessage.crud.insert { cmPinMessageEntity in
               let cmPinMessage = convertPinMessageToCM(pinMessage: pinMessage, entity: cmPinMessageEntity)
                resultEntity?(cmPinMessage)
            }
        }
    }
    
    public class func pinMessage(pinMessage:PinUnpinMessage , threadId:Int?){
        guard let threadId = threadId else{return}
    
        //1-unpin old message if exist
        unpinMessage(pinMessage: pinMessage, threadId: threadId)
        //2-set new pinMessage relation to threadPinMessage property
        let thread = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId)
        insertOrUpdate(pinMessage: pinMessage){ resultEntity in
            thread?.pinMessage  = resultEntity
        }
        //3-set true Message Model
        if let message = CMMessage.crud.find(keyWithFromat: "id == %id", value: pinMessage.messageId)?.getCodable(){
            CMMessage.insertOrUpdate(message: message, conversation: thread){ resultEntity in
                resultEntity.pinned = true
            }
        }
    }
    
    public class func unpinMessage(pinMessage:PinUnpinMessage , threadId:Int?){
        guard let threadId = threadId else{return}
        let thread = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId)
        insertOrUpdate(pinMessage: pinMessage){ resultEntity in
            thread?.pinMessage  = nil
        }
        if let message = CMMessage.crud.find(keyWithFromat: "id == %id", value: pinMessage.messageId)?.getCodable(){
            CMMessage.insertOrUpdate(message: message, conversation: thread){  resultEntity in
                resultEntity.pinned = false
            }
        }
    }
}
