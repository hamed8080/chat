//
//  SendStartTypingRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/15/21.
//

import Foundation
import FanapPodAsyncSDK
class SendStartTypingRequestHandler{
    
    static var isTypingCount = 0
    static var threadId:Int? = nil
    static var timer :RepeatingTimer? = nil
    
    class func handle(_ threadId:Int , _ chat:Chat){
        isTypingCount  = 0
        timer = RepeatingTimer(timeInterval: 2.0)
        timer?.eventHandler = {
            if (self.isTypingCount < 30) {
                self.isTypingCount += 1
                DispatchQueue.main.async {
                    Chat.sharedInstance.newSendSignalMessage(req: .init(signalType: .IS_TYPING , threadId:threadId))
                }
            } else {
                stopTyping()
            }
        }
        timer?.resume()
    }
    
    class func stopTyping(){
        timer?.suspend()
        timer = nil
    }
}
