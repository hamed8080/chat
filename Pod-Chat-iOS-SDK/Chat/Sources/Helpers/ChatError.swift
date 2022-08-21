//
//  ChatError.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import FanapPodAsyncSDK

public enum ChatErrorCodes:String{
    case ASYNC_ERROR            = "ASYNC_ERROR"
    case OUT_OF_STORAGE         = "OUT_OF_STORAGE"
    case ERROR_RAEDY_CHAT       = "ERROR_RAEDY_CHAT"
    case EXPORT_ERROR           = "EXPORT_ERROR"    
    case NETWORK_ERROR          = "NETWORK_ERROR"
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
    public var banError  : BanError?          = nil
    
    internal enum CodingKeys:String , CodingKey{
        case hasError     = "hasError"
        case errorMessage = "errorMessage"
        case errorCode    = "errorCode"
        case code         = "code"
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
        if let errorCode = try containser?.decodeIfPresent(Int.self, forKey: .code),
           errorCode == 208,
           let data = message?.data(using: .utf8),
           let banError = try? JSONDecoder().decode(BanError.self, from: data) {
            self.banError = banError
        }
    }
}

public class BanError:Decodable {
    private let errorMessage:String?
    private let duration:Int?
    private let uniqueId:String?
}

extension AsyncError{

    var chatError:ChatError{
        return ChatError(code: .ASYNC_ERROR, message: message, userInfo: userInfo, rawError: rawError)
    }
}
