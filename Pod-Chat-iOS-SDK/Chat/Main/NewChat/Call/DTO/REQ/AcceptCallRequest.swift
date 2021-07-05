//
//  AcceptCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class AcceptCallRequest:BaseRequest{
    
    let callId     : Int?
    let video      : Bool
    let mute       : Bool
    
    public init(callId: Int,video:Bool = false , mute:Bool = false, typeCode:String? = nil, uniqueId:String? = nil) {
        self.callId     = callId
        self.video      = video
        self.mute       = mute
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    private enum CodingKeys:String,CodingKey{
        
        case video  = "video"
        case mute   = "mute"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mute, forKey: .mute)
        try container.encode(video, forKey: .video)
    }
    
}
