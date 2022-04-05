//
//  UserRCT.swift
//  FanapPodChatSDK
//
//  Created by hamed on 4/3/22.
//

import Foundation
import WebRTC

public enum RTCDirection{
    
    case SEND
    case RECEIVE
    case INACTIVE
}

/// This struct use to save state of a particular call participant which can be a single video or audio user for a call participant because in this system for each call participant we have two user and peerconnection one for audio and one for video or in the future data.
public struct UserRCT:Hashable{
    
    public static func == (lhs: UserRCT, rhs: UserRCT) -> Bool {
        lhs.topic == rhs.topic
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(topic)
    }
    
    public var topic                                :String
    public var direction                            :RTCDirection
    public var pf                                   :RTCPeerConnectionFactory?  = nil
    public var pc                                   :RTCPeerConnection?         = nil
    public var renderer                             :RTCVideoRenderer?          = nil
    public var videoTrack                           :RTCVideoTrack?             = nil
    private (set) var audioTrack                    :RTCAudioTrack?             = nil
    public private (set) var callParticipant        :CallParticipant?           = nil
    public var dataChannel                          :RTCDataChannel?            = nil
    public var isSpeaking                           :Bool                       = false
    public var lastTimeSpeaking                     :Date?                      = nil
    
    mutating func setVideoTrack(_ videoTrack:RTCVideoTrack?){
        self.videoTrack = videoTrack
    }
    
    mutating func setAudioTrack(_ audioTrack:RTCAudioTrack?){
        self.audioTrack = audioTrack
    }
    
    public var constraints:[String:String]{
        var const:[String:String] = [:]
        let videoKey = kRTCMediaConstraintsOfferToReceiveVideo
        let audioKey = kRTCMediaConstraintsOfferToReceiveAudio
        let trueValue = kRTCMediaConstraintsValueTrue
        let falseValue = kRTCMediaConstraintsValueFalse
        
        const[videoKey] = falseValue
        const[audioKey] = falseValue
        if direction == .RECEIVE{
            if isVideoTopic{
                const[videoKey] = trueValue
            }else{
                const[audioKey] = trueValue
            }
        }
        return const
    }
    
    mutating func setPeerFactory(_ pf:RTCPeerConnectionFactory){
        self.pf = pf
    }
    
    mutating func setPeerConnection(_ pc:RTCPeerConnection){
        self.pc = pc
    }
    
    public var isVideoTopic:Bool{
        topic.contains("Vi-")
    }
    
    public var isAudioTopic:Bool{
        topic.contains("Vo-")
    }
    
    public var rawTopicName:String{
        return topic.replacingOccurrences(of: "Vi-", with: "").replacingOccurrences(of: "Vo-", with: "")
    }
    
    mutating func setUsetIsSpeaking(){
        isSpeaking = true
        lastTimeSpeaking = Date()
    }
    
    mutating func setUsetStoppedSpeaking(){
        isSpeaking = false
        lastTimeSpeaking = nil
    }
    
    private mutating func setVideoTrack(enable:Bool){
        videoTrack?.isEnabled = enable
    }
    
    private mutating func setAudioTrack(enable:Bool){
        audioTrack?.isEnabled = enable
    }
    
    public var isMute:Bool{
        return callParticipant?.mute ?? true
    }
    
    public var isVideoOn:Bool{
        return callParticipant?.video ?? false
    }
    
    public var isVideoTrackEnable:Bool{
        return videoTrack?.isEnabled ?? false
    }
    
    public var isAudioTrackEnable:Bool{
        return audioTrack?.isEnabled ?? false
    }
    
    public mutating func setCallParticipant(_ callParticipant:CallParticipant?){
        self.callParticipant = callParticipant
    }
    
    public mutating func setVideo(on:Bool){
        setVideoTrack(enable: on)
        callParticipant?.video = on
    }
    
    public mutating func setMute(mute:Bool){
        setAudioTrack(enable: !mute)
        callParticipant?.mute = mute
    }
}
