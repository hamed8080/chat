//
//  StartCallRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class StartCallRequestHandler {
	
	class func handle( _ req:StartCallRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<CreateCall> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.callState = .Requested
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
								messageType: .START_CALL_REQUEST,
								uniqueIdResult: uniqueIdResult){ response in
			completion(response.result as? CreateCall,response.uniqueId , response.error)
		}
        startTimerTimeout()
	}
    
    ///if newtork is unstable and async server cant respond with type CALL_SESSION_CREATED then we must end call  for starter to close UI
    class func startTimerTimeout(){
        let chat = Chat.sharedInstance
        Timer.scheduledTimer(withTimeInterval: chat.config?.callTimeout ?? 0, repeats: false) { timer in
            if chat.callState == .Requested{
                if chat.config?.isDebuggingLogEnabled == true{
                    print("cancel call after \(chat.config?.callTimeout ?? 0) second no response back from server with type CALL_SESSION_CREATED")
                }
                
                NotificationCenter.default.post(name: END_CALL_NAME_OBJECT ,object: 0)
                chat.callState = .Ended
            }
            timer.invalidate()
        }
    }
	
}
