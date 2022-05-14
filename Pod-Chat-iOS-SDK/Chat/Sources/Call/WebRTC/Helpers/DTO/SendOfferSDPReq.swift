//
//  SendOfferSDPReq.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation

struct SendOfferSDPReq: Codable {
   
    var id                  :String     = "RECIVE_SDP_OFFER"
    var brokerAddress       :String
    var token               :String
    var topic               :String
    var sdpOffer            :String
    private var mediaType   :Mediatype
    private var useComedia              = true
    private var useSrtp                 = false

    var unqiueId                        = UUID().uuidString
    
    public init(id: String = "RECIVE_SDP_OFFER", brokerAddress: String, token: String,topic:String,sdpOffer:String , mediaType:Mediatype) {
        self.id            = id
        self.brokerAddress = brokerAddress
        self.token         = token
        self.topic         = topic
        self.sdpOffer      = sdpOffer
        self.mediaType     = mediaType
    }
    
}

public enum Mediatype:Int,Codable {
    case AUDIO = 1
    case VIDEO = 2
}
