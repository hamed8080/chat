//
//  SendCandidateReq.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation

struct SendCandidateReq: Codable {
   
    var id            :String = "ADD_ICE_CANDIDATE"
    var token         :String
    var topic         :String
    var candidate     :IceCandidate
    var unqiueId      :String
    
    public init(id: String = "ADD_ICE_CANDIDATE", token: String,topic:String,candidate:IceCandidate) {
        self.id            = id
        self.token         = token
        self.topic         = topic
        self.candidate     = candidate
        self.unqiueId      = UUID().uuidString
    }
    
    private enum CodingKeys:String,CodingKey{
         case id            = "id"
         case token         = "token"
         case topic         = "topic"
         case candidate     = "candidateDto"
         case unqiueId      = "unqiueId"
    }
    
}
