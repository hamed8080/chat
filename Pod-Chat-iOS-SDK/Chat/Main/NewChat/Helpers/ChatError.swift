//
//  ChatError.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation

public struct ChatError:Decodable{
    var message   :String?
    let errorCode :Int?
    let hasError  :Bool?
    let content   :String?
    
    
    internal enum CodingKeys:String , CodingKey{
        case hasError     = "hasError"
        case errorMessage = "errorMessage"
        case errorCode    = "errorCode"
        case content      = "content"
        case message      = "message"
    }
    
    init(message:String?  = nil, errorCode:Int? = nil, hasError:Bool? = nil , content:String? = nil){
        self.message   = message
        self.errorCode = errorCode
        self.hasError  = hasError
        self.content   = content
    }
    
    public init(from decoder: Decoder) throws {
        let containser = try? decoder.container(keyedBy: CodingKeys.self)
        hasError  = try containser?.decodeIfPresent(Bool.self, forKey: .hasError)
        message   = try containser?.decodeIfPresent(String.self, forKey: .errorMessage)
        errorCode = try containser?.decodeIfPresent(Int.self, forKey: .errorCode)
        content   = try containser?.decodeIfPresent(String.self, forKey: .content)
        if let msg = try containser?.decodeIfPresent(String.self, forKey: .message){
            message = msg
        }
    }
}
