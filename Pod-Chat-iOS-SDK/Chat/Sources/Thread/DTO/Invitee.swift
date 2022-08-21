//
//  Invitee.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//
import Foundation

open class Invitee : Codable{
    
    public var id     : String?
    public var idType : Int?
 
    public init(id:String?, idType: InviteeTypes?) {
        self.id = id
        self.idType = idType?.rawValue
    }
    
}
