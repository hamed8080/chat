//
//  ChatError.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import FanapPodAsyncSDK


public enum ChatErrorCodes:String{
    case ASYNC_ERROR      = "ASYNC_ERROR"
    case OUT_OF_STORAGE   = "OUT_OF_STORAGE"
    case ERROR_RAEAY_CHAT = "ERROR_RAEAY_CHAT"
    case UNDEFINED
}

public struct ChatError:Decodable{
    
    public var message   : String?            = nil
    public var errorCode : Int?               = nil
    public var hasError  : Bool?              = nil
    public var content   : String?            = nil
    public var userInfo  : [String:Any]?      = nil
    public var rawError  : Error?             = nil
    public var code      : ChatErrorCodes     = .UNDEFINED
    
    internal enum CodingKeys:String , CodingKey{
        case hasError     = "hasError"
        case errorMessage = "errorMessage"
        case errorCode    = "errorCode"
        case content      = "content"
        case message      = "message"
    }
    
    public init(code: ChatErrorCodes = .UNDEFINED , errorCode:Int? = nil, message: String? = nil, userInfo: [String : Any]? = nil, rawError:Error? = nil, content:String? = nil) {
        self.code       = code
        self.message    = message
        self.userInfo   = userInfo
        self.rawError   = rawError
        self.errorCode  = errorCode
        self.content    = content
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

extension AsyncError{

    var chatError:ChatError{
        return ChatError(code: .ASYNC_ERROR, message: message, userInfo: userInfo, rawError: rawError)
    }
}
