//
//  WebRTCClientNew.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/8/21.
//

import Foundation
import WebRTC
import FanapPodAsyncSDK

public enum RTCDirection{
    
    case SEND
    case RECEIVE
    case INACTIVE
}

public struct UserRCT:Hashable{
    
    public static func == (lhs: UserRCT, rhs: UserRCT) -> Bool {
        lhs.topic == rhs.topic
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(topic)
    }
    
    public var topic               :String
    public var direction           :RTCDirection
    public var pf                  :RTCPeerConnectionFactory?  = nil
    public var pc                  :RTCPeerConnection?         = nil
    public var renderer            :RTCVideoRenderer?          = nil
    public var videoTrack          :RTCVideoTrack?             = nil
    public var audioTrack          :RTCAudioTrack?             = nil
    public var callParticipant     :CallParticipant?           = nil
    public var dataChannel         :RTCDataChannel?            = nil
    
    mutating func setVideoTrack(_ videoTrack:RTCVideoTrack?){
        self.videoTrack = videoTrack
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
            if isVideo{
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
    
    public var isVideo:Bool{
        topic.contains("Vi-")
    }
    
    public var rawTopicName:String{
        return topic.replacingOccurrences(of: "Vi-", with: "").replacingOccurrences(of: "Vo-", with: "")
    }
}

// MARK: - Pay attention, this class use many extensions inside a files not be here.
public class WebRTCClientNew : NSObject, RTCPeerConnectionDelegate, RTCDataChannelDelegate{
    
    public static var instance      :WebRTCClientNew?                  = nil//for call methods when new message arrive from server
    private var answerReceived      :[String:RTCPeerConnection]        = [:]
    
    
    private var config              :WebRTCConfig
    private var delegate            :WebRTCClientDelegate?
    public  var usersRTC            :[UserRCT] = []
    private var videoCapturer       :RTCVideoCapturer?
    private var localDataChannel    :RTCDataChannel?
    private var isFrontCamera       :Bool                       = true
    private var videoSource         :RTCVideoSource?
    private var iceQueue            :[(pc:RTCPeerConnection,ice:RTCIceCandidate)] = []
    var targetLocalVideoWidth       :Int32 = 640
    var targetLocalVideoHight       :Int32 = 480
    var targetFPS                   :Int32 = 15
    var logFile                     :RTCFileLogger? = nil
    
    private let rtcAudioSession     = RTCAudioSession.sharedInstance()
    private let audioQueue          = DispatchQueue(label: "audio")
    
    public init(config:WebRTCConfig, delegate:WebRTCClientDelegate? = nil) {
        self.delegate                       = delegate
        self.config                         = config
        RTCInitializeSSL()
        print(config)
        super.init()
        Chat.sharedInstance.callState = .InitializeWEBRTC
        WebRTCClientNew.instance            = self
        
        // Console output
        //        RTCSetMinDebugLogLevel(RTCLoggingSeverity.info)
        
        // File output
        saveLogsToFile()
    }


    func createPeerCpnnectionFactoryForTopic(topic:String?){
        if let topic = topic{
            let encoder = RTCDefaultVideoEncoderFactory.default
            let decoder = RTCDefaultVideoDecoderFactory.default
            let pcf = RTCPeerConnectionFactory(encoderFactory: encoder, decoderFactory: decoder)
            let op = RTCPeerConnectionFactoryOptions()
            //            op.disableEncryption = true
            pcf.setOptions(op)
            if let index = indexFor(topic: topic){
                usersRTC[index].setPeerFactory(pcf)
            }
        }
    }

    private func createPeerConnection(_ topic:String?){
        if let topic = topic,
           let pcf = userFor(topic: topic)?.pf,
           let constraints = userFor(topic: topic)?.constraints,
           let pc = pcf.peerConnection(with: rtcConfig, constraints: .init(mandatoryConstraints: constraints, optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue]), delegate: nil) {
            pc.delegate     = self
            if let index = indexFor(topic: topic){
                usersRTC[index].setPeerConnection(pc)
            }
        }else{
            customPrint("can't create peerConnection check configration and initialization in gropup",isGuardNil: true)
        }
    }
    
    private var rtcConfig:RTCConfiguration{
        let rtcConfig                            = RTCConfiguration()
        rtcConfig.sdpSemantics                   = .unifiedPlan
        rtcConfig.iceTransportPolicy             = .relay
        rtcConfig.continualGatheringPolicy       = .gatherContinually
        rtcConfig.iceServers                     = [RTCIceServer(urlStrings: config.iceServers,username: config.userName!,credential: config.password!)]
        return rtcConfig
    }
    
    public func createTopic(topic:String, direction:RTCDirection, renderer:RTCVideoRenderer? = nil){
        usersRTC.append(.init(topic: topic, direction: direction, renderer: renderer))
        createPeerCpnnectionFactoryForTopic(topic: topic)
        createPeerConnection(topic)
    }
    
    
    public func createSession(){
        createMediaSenders()
        configureAudioSession()
        let session = CreateSessionReq(turnAddress: config.turnAddress, brokerAddress: config.brokerAddressWeb, token: Chat.sharedInstance.token)
        if let data = try? JSONEncoder().encode(session){
            send(data)
        }else{
            customPrint("can't create session decoder was nil",isGuardNil: true)
        }
    }
    
    public func addCallParticipant(_ callParticipant:CallParticipant, direction:RTCDirection){
        
        createTopic(topic: topics(callParticipant).topicVideo, direction: direction, renderer: RTCMTLVideoView(frame: .zero))
        createTopic(topic: topics(callParticipant).topicAudio, direction: direction)
        if let index = indexFor(topic: topics(callParticipant).topicVideo){
            usersRTC[index].callParticipant = callParticipant
        }
        
        if let index = indexFor(topic: topics(callParticipant).topicAudio){
            usersRTC[index].callParticipant = callParticipant
        }
        
        if direction == .RECEIVE{
            addReceiveVideoStream(topic: topics(callParticipant).topicVideo)
            addReceiveAudioStream(topic: topics(callParticipant).topicAudio)
            getOfferAndSendToPeer(topic: topics(callParticipant).topicVideo)
            getOfferAndSendToPeer(topic: topics(callParticipant).topicAudio)
        }
    }
    
    public func removeCallParticipant(_ callParticipant:CallParticipant){
        removeTopic(topic: topics(callParticipant).topicVideo)
        removeTopic(topic: topics(callParticipant).topicAudio)
    }
    
    func removeTopic(topic:String){
        if let index = indexFor(topic: topic){
            usersRTC[index].pc?.close()
            usersRTC.remove(at: index)
        }
    }
    
    private func setConnectedState(peerConnection:RTCPeerConnection){
        customPrint("--- \(getPCName(peerConnection)) connected ---" , isSuccess: true)
        delegate?.didConnectWebRTC()
    }
    
    /** Called when connction state change in RTCPeerConnectionDelegate. */
    private func setDisconnectedState(peerConnection:RTCPeerConnection){
        customPrint("--- \(getPCName(peerConnection)) disconnected ---" , isGuardNil: true)
        self.delegate?.didDisconnectWebRTC()
    }
    
    /// Client can call this to dissconnect from peer.
    public func clearResourceAndCloseConnection(){
        usersRTC.forEach { userRTC in
            customPrint("--- closing \(userRTC.topic) ---" , isGuardNil: true)
            userRTC.pc?.close()
        }
        let close = CloseSessionReq(token: Chat.sharedInstance.token)
        guard let data = try? JSONEncoder().encode(close) else {
            customPrint("error to encode close session request ", isGuardNil: true)
            return
        }
        logFile?.stop()
        send(data)
        usersRTC = []
        (videoCapturer as? RTCCameraVideoCapturer)?.stopCapture()
        WebRTCClientNew.instance = nil
    }
    
    public func getLocalSDPWithOffer(topic:String ,onSuccess:@escaping (RTCSessionDescription)->Void){
        guard let mediaConstraint = userFor(topic: topic)?.constraints else{
            customPrint("can't find mediaConstraint to get local offer",isGuardNil: true)
            return
        }
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: mediaConstraint, optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueFalse])
        guard let pp = userFor(topic: topic)?.pc else{
            customPrint("can't find peerConnection in map to get local offer",isGuardNil: true)
            return
        }
        pp.offer(for: constraints, completionHandler: { sdp, error in
            if let error = error{
                self.customPrint("can't get offer SDP from SDK",error, isGuardNil: true)
            }
            guard let sdp = sdp else {
                self.customPrint("sdp was nil with no error!", isGuardNil: true)
                return
            }
            pp.setLocalDescription(sdp, completionHandler: { (error) in
                if let error = error{
                    self.customPrint("error setLocalDescription for offer",error, isGuardNil: true)
                    return
                }
                onSuccess(sdp)
            })
        })
    }
    
    public func sendOfferToPeer(_ sdp:RTCSessionDescription,topic:String){
        let sdp = sdp.sdp
        let mediaType:Mediatype = userFor(topic: topic)?.isVideo ?? false ? .VIDEO : .AUDIO
        let sendSDPOffer = SendOfferSDPReq(id: isSendTopic(topic: topic) ? "SEND_SDP_OFFER" : "RECIVE_SDP_OFFER" ,
                                           brokerAddress: config.firstBorokerAddressWeb,
                                           token: Chat.sharedInstance.token,
                                           topic: topic,
                                           sdpOffer: sdp ,
                                           mediaType: mediaType)
        guard let data = try? JSONEncoder().encode(sendSDPOffer) else {
            self.customPrint("error to encode SDP offer", isGuardNil: true)
            return
        }
        send(data)
    }
    
    public func send(_ data:Data){
        if let content = String(data: data, encoding: .utf8){
            Chat.sharedInstance.prepareToSendAsync(content,peerName: config.peerName)
        }else{
            self.customPrint("cant convert data to string in send", isGuardNil: true)
        }
    }
    
    private func createMediaSenders(){
        //Send Audio
        if let audioTrack = createAudioTrack() , let topicAudioSend = config.topicAudioSend, let index = indexFor(topic: topicAudioSend){
            usersRTC[index].audioTrack = audioTrack
            usersRTC[index].pc?.add(audioTrack, streamIds: [topicAudioSend])
        }
        
        //Video
        if let topicVideoSend = config.topicVideoSend, let videoTrack = createVideoTrack(), let index = indexFor(topic: topicVideoSend){
            usersRTC[index].videoTrack = videoTrack
            usersRTC[index].pc?.add(videoTrack, streamIds: [topicVideoSend])
            if let renderer = userFor(topic: topicVideoSend)?.renderer{
                startCaptureLocalVideo(renderer: renderer, fileName: "")
            }
        }
        
        if let topicVideoRecieve = config.topicVideoReceive{
            addReceiveVideoStream(topic: topicVideoRecieve)
        }
        
        if let topicAudioRecieve = config.topicAudioReceive{
            addReceiveAudioStream(topic: topicAudioRecieve)
        }
    }
    
    public func addReceiveVideoStream(topic:String){
        if let index = indexFor(topic: topic){
            var error:NSError?
            let videoReceivetransciver = usersRTC[index].pc?.addTransceiver(of: .video)
            videoReceivetransciver?.setDirection(.recvOnly, error: &error)
            if let remoteVideoTrack = videoReceivetransciver?.receiver.track as? RTCVideoTrack{
                usersRTC[index].videoTrack = remoteVideoTrack
                usersRTC[index].pc?.add(remoteVideoTrack, streamIds: [topic])
                if let renderer = usersRTC[index].renderer{
                    usersRTC[index].videoTrack?.add(renderer)
                }
            }
        }
    }
    
    public func addReceiveAudioStream(topic:String){
        if let index = indexFor(topic: topic){
            var error:NSError?
            let transciver = usersRTC[index].pc?.addTransceiver(of: .audio)
            transciver?.setDirection(.recvOnly, error: &error)
            if let remoteAudioTrack = transciver?.receiver.track as? RTCAudioTrack {
                usersRTC[index].audioTrack = remoteAudioTrack
                usersRTC[index].pc?.add(remoteAudioTrack, streamIds: [config.topicAudioReceive ?? ""])
                monitorAudioLevelFor(topic: topic)
            }
        }
    }
    
    func monitorAudioLevelFor(topic:String){
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            if let user = self.userFor(topic: topic){
                user.pc?.statistics(completionHandler: { report in
                    report.statistics.values.filter({$0.type == "track"}).forEach { stat in
                        let level = (stat.values["audioLevel"] as? Double) ?? .zero
                        print("call participant:\(user.callParticipant?.participant?.name ?? user.callParticipant?.participant?.username ?? "") audio level:\(level)")
                    }
                })
            }else{
                timer.invalidate()
            }
        }
    }
    
    private func createVideoTrack()->RTCVideoTrack?{
        guard let topicVideoSend = config.topicVideoSend, let pcfSendVideo = userFor(topic: topicVideoSend)?.pf else {
            self.customPrint("topic or peerconectionfactory in createVideoTrack was nuil maybe it was audio call!",isGuardNil: true)
            return nil
        }
        let videoSource = pcfSendVideo.videoSource()
        self.videoSource = videoSource
#if targetEnvironment(simulator)
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
#else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
#endif
        
        let videoTrack = pcfSendVideo.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    private func createAudioTrack()->RTCAudioTrack?{
        guard let topicAudioSend = config.topicAudioSend ,let mediaConstraint = userFor(topic: topicAudioSend)?.constraints, let pcfAudioSend = userFor(topic: topicAudioSend)?.pf else{
            self.customPrint("topic or peerconectionfactory in createAudioTrack or media constarint audio send not found!",isGuardNil: true)
            return nil
        }
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints:mediaConstraint, optionalConstraints: nil)
        let audioSource = pcfAudioSend.audioSource(with: audioConstrains)
        let audioTrack = pcfAudioSend.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    private func generateSendKeyFrame(){
        //        guard let format = getCameraFormat() , let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate else {
        //            self.customPrint("get camera descripton for gereate key frame was nil!",isGuardNil:true)
        //            return
        //        }
        //        let desc = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
       
        
        self.customPrint("resize to get key frame")
        //        localVideoTrack?.isEnabled = false
        if let topic = config.topicVideoSend, let index = indexFor(topic: topic){
            usersRTC[index].videoTrack?.source.adaptOutputFormat(toWidth: targetLocalVideoWidth + 50, height: targetLocalVideoHight, fps: targetFPS)
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self]timer in
                guard let self = self else{
                    self?.customPrint("self was nil in timer generate keyFrame!",isGuardNil:true)
                    return
                }
                DispatchQueue.main.async {
                    self.customPrint("resize to normal generate key frame")
                    if self.usersRTC.count == 0{return}
                    self.usersRTC[index].videoTrack?.source.adaptOutputFormat(toWidth: self.targetLocalVideoWidth, height: self.targetLocalVideoHight, fps: self.targetFPS)
                }
            }
        }
    }
    
    public func startCaptureLocalVideo(renderer:RTCVideoRenderer , fileName:String){
        if let capturer = videoCapturer as? RTCCameraVideoCapturer{
            guard let selectedCamera = RTCCameraVideoCapturer.captureDevices().first(where: {$0.position == (isFrontCamera ? .front : .back) }),
                  let format = getCameraFormat()
            else{
                self.customPrint("error happend to startCaptureLocalVideo",isGuardNil:true)
                return
            }
            self.customPrint("target fps :\(targetFPS)")
            DispatchQueue.global(qos: .background).async {
                capturer.startCapture(with: selectedCamera, format: format, fps: Int(self.targetFPS))
            }
            addRendererToLocalVideoTrack(renderer)
        }else if let capturer = videoCapturer as? RTCFileVideoCapturer{
            capturer.startCapturing(fromFileNamed: fileName , onError: { error in
                self.customPrint("error on read from mp4 file" , error,isGuardNil:true)
            })
            addRendererToLocalVideoTrack(renderer)
        }
    }
    
    private func getCameraFormat()->AVCaptureDevice.Format?{
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: {$0.position == (isFrontCamera ? .front : .back) }) else {
            self.customPrint("error to find front camera" ,isGuardNil:true)
            return nil
        }
        let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera).last(where: { format in
            let maxFrameRate = format.videoSupportedFrameRateRanges.first(where: { $0.maxFrameRate <= Float64(targetFPS) })?.maxFrameRate ?? Float64(targetFPS)
            self.targetFPS = Int32(maxFrameRate)
            return CMVideoFormatDescriptionGetDimensions(format.formatDescription).width == targetLocalVideoWidth && CMVideoFormatDescriptionGetDimensions(format.formatDescription).height == targetLocalVideoHight && Int32(maxFrameRate) <= targetFPS
        })
        return format
    }
    
    public func switchCameraPosition(renderer:RTCVideoRenderer){
        if let capturer = videoCapturer as? RTCCameraVideoCapturer{
            capturer.stopCapture {
                self.isFrontCamera.toggle()
                self.startCaptureLocalVideo(renderer:renderer,fileName: "")
            }
        }
    }
    
    func addRendererToLocalVideoTrack(_ renderer:RTCVideoRenderer){
        if let topic = config.topicVideoSend ,let index = indexFor(topic: topic){
            usersRTC[index].videoTrack?.add(renderer)
        }
    }
    
    deinit {
        customPrint("deinit webrtc client called")
    }
    
    func customPrint(_ message:String , _ error:Error? = nil , isSuccess:Bool = false ,isGuardNil:Bool = false){
        let errorMessage = error != nil ? " with error:\(error?.localizedDescription ?? "")" : ""
        let icon = isGuardNil ? "❌" : isSuccess ? "✅" : ""
        Chat.sharedInstance.logger?.log(title: "CHAT_SDK:\(icon)", message: "\(message) \(errorMessage)")
    }
    
    func userFor(topic:String)->UserRCT?{
        return usersRTC.first(where: {$0.topic == topic})
    }
    
    func indexFor(topic:String)->Int?{
        return usersRTC.firstIndex(where: {$0.topic == topic})
    }
    
    func saveLogsToFile(){
        if Chat.sharedInstance.config?.isDebuggingLogEnabled == true , let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true){
            let logFilePath = "WEBRTC-LOG"
            let url = dir.appendingPathComponent(logFilePath)
            customPrint("created path for log is :\(url.path)")
            
            logFile = RTCFileLogger(dirPath: url.path, maxFileSize: 100 * 1024)
            logFile?.severity = .info
            logFile?.start()
        }
    }
    
    private func topics(_ callParticipant:CallParticipant)->(topicVideo:String,topicAudio:String){
        return ("Vi-\(callParticipant.sendTopic)","Vo-\(callParticipant.sendTopic)")
    }
    
    public func  updateCallParticipant(callParticipants:[CallParticipant]?){
        if let callParticipants = callParticipants {
            callParticipants.forEach { callParticipant in
                usersRTC.filter{ $0.rawTopicName == callParticipant.sendTopic}.forEach{ user in
                    let index = usersRTC.firstIndex(of: user)!
                    usersRTC[index].callParticipant = callParticipant
                }
            }
        }
    }
    
}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCClientNew{
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        customPrint("\(getPCName(peerConnection))  signaling state changed: \(String(describing: stateChanged.stringValue))")
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        customPrint("\(getPCName(peerConnection)) did add stream")
        if let videoTrack = stream.videoTracks.first, let topic = getTopicForPeerConnection(peerConnection), let renderer = userFor(topic: topic)?.renderer
        {
            customPrint("\(getPCName(peerConnection)) did add stream video track topic: \(topic)")
            videoTrack.add(renderer)
        }
        
        if let audioTrack = stream.audioTracks.first,let topic = getTopicForPeerConnection(peerConnection)
        {
            customPrint("\(getPCName(peerConnection)) did add stream audio track topic: \(topic)")
            userFor(topic: topic)?.pc?.add(audioTrack, streamIds: [topic])
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        customPrint("\(getPCName(peerConnection)) did remove stream")
    }
    
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        customPrint("\(getPCName(peerConnection)) should negotiate")
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else{
                self?.customPrint("self was nil in peerconnection didchange state",isGuardNil: true)
                return
            }
            self.customPrint("\(self.getPCName(peerConnection)) connection state changed to: \(String(describing:newState.stringValue))")
            switch newState {
            case .connected, .completed:
                self.setConnectedState(peerConnection: peerConnection)
            case .disconnected:
                self.setDisconnectedState(peerConnection:peerConnection)
                break
            case .failed:
                self.reconnectAndGetOffer(peerConnection)
                break
            default:
                break
            }
            self.delegate?.didIceConnectionStateChanged(iceConnectionState: newState)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        customPrint("\(getPCName(peerConnection)) did change new state")
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        let relayStr = candidate.sdp.contains("typ relay") ? "Yes ✅✅✅✅✅✅" : "No ⛔️⛔️⛔️⛔️⛔️⛔️⛔️"
        customPrint("\(getPCName(peerConnection)) did generate ICE Candidate is relayType:\(relayStr)")
        sendIceIfAnswerPresent(peerConnection, candidate)
    }
    
    private func sendIceIfAnswerPresent(_ peerConnection:RTCPeerConnection, _ candidate:RTCIceCandidate){
        
        guard let topicName = getTopicForPeerConnection(peerConnection) else{
            customPrint("can't find topic name to send ICE Candidate" , isGuardNil: true)
            return
        }
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {[weak self] timer in
                guard let self = self else {return}
                if self.userFor(topic: topicName)?.pc?.remoteDescription != nil{
                    let sendIceCandidate = SendCandidateReq(token: Chat.sharedInstance.token,
                                                            topic: topicName,
                                                            candidate: IceCandidate(from: candidate).replaceSpaceSdpIceCandidate)
                    guard let data = try? JSONEncoder().encode(sendIceCandidate) else {
                        self.customPrint("cannot encode genereated ice to send to server!" , isGuardNil: true)
                        return
                    }
                    self.customPrint("ice sended to server")
                    self.send(data)
                    timer.invalidate()
                }else{
                    let pcName  = self.getPCName(peerConnection)
                    self.customPrint("answer is not present yet for \(pcName) timer will fire in 0.5 second" , isGuardNil: true)
                }
            }
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        customPrint("\(getPCName(peerConnection)) did remove candidate(s)")
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        customPrint("\(getPCName(peerConnection)) did open data channel \(dataChannel)")
        let topic = getPCName(peerConnection)
        var user = userFor(topic: topic)
        user?.dataChannel = dataChannel
    }
    
    private func isSendTopic(topic:String)->Bool{
        return topic == config.topicAudioSend || topic == config.topicVideoSend
    }
    
    private func getPCName(_ peerConnection:RTCPeerConnection)->String{
        guard let topic = getTopicForPeerConnection(peerConnection) else {return ""}
        let isSend  = isSendTopic(topic: topic)
        let isVideo = userFor(topic: topic)?.isVideo ?? false
        return "peerConnection\(isSend ? "Send" : "Receive")\(isVideo ? "Video" : "Audio") topic:\(topic)"
    }
    
    private func getTopicForPeerConnection(_ peerConnection:RTCPeerConnection)->String?{
        return usersRTC.first(where: {$0.pc == peerConnection})?.topic
    }
    
    public func setCameraIsOn(_ isCameraOn:Bool){
        guard let topicVideoSend = config.topicVideoSend else {
            customPrint("topicVideoSend was nil! setCameraIsOn not working!",isGuardNil: true)
            return
        }
        userFor(topic: topicVideoSend)?.pc?.senders.first?.track?.isEnabled = isCameraOn
    }
    
    public func setMute(_ isMute:Bool){
        guard let topicAudioSend = config.topicAudioSend else {
            customPrint("topicAudioSend was nil! setMute not working!",isGuardNil: true)
            return
        }
        userFor(topic: topicAudioSend)?.pc?.senders.first?.track?.isEnabled = !isMute
    }
}

// MARK: - RTCDataChannelDelegate
extension WebRTCClientNew {
    
    public func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        DispatchQueue.main.async {
            if buffer.isBinary {
                self.delegate?.didReceiveData(data: buffer.data)
            }else {
                self.delegate?.didReceiveMessage(message: String(data: buffer.data, encoding: String.Encoding.utf8)!)
            }
        }
    }
    
    public func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        customPrint("data channel did changeed state to \(dataChannel.readyState)")
    }
}

//MARK: - OnReceive Message from Async Server
extension WebRTCClientNew{
    
    func messageReceived(_ message:NewAsyncMessage){
        guard let content = message.content, let data = content.data(using: .utf8) ,  let ms = try? JSONDecoder().decode(WebRTCAsyncMessage.self, from: data) else {
            customPrint("can't decode data from webrtc servers",isGuardNil: true)
            return
        }
        customPrint("on Call message received\n\(String(data:data,encoding:.utf8) ?? "")")
        switch ms.id {
        case .SESSION_REFRESH,.CREATE_SESSION,.SESSION_NEW_CREATED:
            DispatchQueue.main.async {
                Chat.sharedInstance.sotpAllSignalingServerCall(peerName: self.config.peerName)
            }
            break
        case .ADD_ICE_CANDIDATE:
            addIceToPeerConnection(data)
            break
        case .PROCESS_SDP_ANSWER:
            addSDPAnswerToPeerConnection(data)
            break
        case .GET_KEY_FRAME:
            break
        case .CLOSE:
            break
        case .STOP_ALL:
            setOffers()
            break
        case .STOP:
            break
        case .UNKOWN:
            customPrint("a message received from unkown type form webrtc server",isGuardNil: true)
            break
        }
    }
    
    public func startSendKeyFrame(){
        var count:Double = 0
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) {[weak self] timer in
                guard let self = self else {return}
                if count < 500{
                    self.generateSendKeyFrame()
                }else{
                    timer.invalidate()
                    return
                }
                count  = count + 1
            }
        }
    }
    
    func addSDPAnswerToPeerConnection(_ data:Data){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else{
                self?.customPrint("self was nil on add remote SDP Answer ",isGuardNil: true)
                return
            }
            guard let remoteSDP = try? JSONDecoder().decode(RemoteSDPRes.self, from: data)else{
                self.customPrint("error decode prosessAnswer",isGuardNil: true)
                return
            }
            let pp = self.userFor(topic: remoteSDP.topic)?.pc
            pp?.statistics(completionHandler: { report in
            })
            pp?.setRemoteDescription(remoteSDP.rtcSDP, completionHandler: { error in
                if let error = error{
                    self.customPrint("error in setRemoteDescroptoin with for topic:\(remoteSDP.topic) sdp: \(remoteSDP.rtcSDP)",error,isGuardNil: true)
                }
            })
        }
    }
    
    ///check if remote descriptoin already seted otherwise add it in to queue until set remote description then add ice to peer connection
    func addIceToPeerConnection(_ data:Data){
        guard let candidate = try? JSONDecoder().decode(RemoteCandidateRes.self, from: data) else{
            self.customPrint("error decode ice candidate received from server!",isGuardNil: true)
            return
        }
        
        let rtcIce = candidate.rtcIceCandidate
        guard let pp = userFor(topic: candidate.topic)?.pc else {
            self.customPrint("error finding topic or peerconnection",isGuardNil: true)
            return
        }
        
        if pp.remoteDescription != nil{
            setRemoteIceOnMainThread(pp, rtcIce)
        }else{
            iceQueue.append((pp, rtcIce))
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] timer in
                guard let self = self else {return}
                let pcName = self.getPCName(pp)
                if pp.remoteDescription != nil{
                    self.setRemoteIceOnMainThread(pp, rtcIce)
                    self.iceQueue.remove(at: self.iceQueue.firstIndex{ $0.ice == rtcIce}!)
                    self.customPrint("ICE added to \(pcName) from Queue and remaining in Queue is: \(self.iceQueue.count)")
                    timer.invalidate()
                }
            }
        }
    }
    
    private func setRemoteIceOnMainThread(_ peerCnnection:RTCPeerConnection , _ rtcIce:RTCIceCandidate ){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            peerCnnection.add(rtcIce){ error in
                if let error = error {
                    self.customPrint("error on add ICE Candidate with ICE:\(rtcIce.sdp)", error,isGuardNil: true)
                }
            }
        }
    }
}

// configure audio session
extension WebRTCClientNew{
    
    private func configureAudioSession() {
        self.customPrint("configure audio session")
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.rtcAudioSession.setMode(AVAudioSessionModeVoiceChat)
        } catch let error {
            customPrint("error changeing AVAudioSession category",error,isGuardNil: true)
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    public func setSpeaker(on:Bool){
        self.audioQueue.async { [weak self] in
            self?.customPrint("request to setSpeaker:\(on)")
            guard let self = self else {
                self?.customPrint("self was nil set speaker mode!",isGuardNil: true)
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try self.rtcAudioSession.overrideOutputAudioPort(on ? .speaker : .none)
                if on{ try self.rtcAudioSession.setActive(true) }
            } catch let error {
                self.customPrint("can't change audio speaker",error,isGuardNil: true)
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
}

extension WebRTCClientNew{
    
    public func setOffers(){
        usersRTC.forEach { userRTC in
            getOfferAndSendToPeer(topic: userRTC.topic)
        }
    }
    
    public func getOfferAndSendToPeer(topic:String){
        getLocalSDPWithOffer(topic: topic , onSuccess: { rtcSession in
            self.sendOfferToPeer(rtcSession, topic: topic)
        })
    }
    
    func reconnectAndGetOffer(_ peerConnection:RTCPeerConnection){
        guard let topic = getTopicForPeerConnection(peerConnection)else{
            customPrint("can't find topic to reconnect peerconnection",isGuardNil: true)
            return
        }
        customPrint("restart to get new SDP and send offer")
        self.getOfferAndSendToPeer(topic: topic)
    }
}
