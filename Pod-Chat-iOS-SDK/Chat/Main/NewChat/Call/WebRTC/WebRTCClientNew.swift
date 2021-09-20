//
//  WebRTCClientNew.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/8/21.
//

import Foundation
import WebRTC
import FanapPodAsyncSDK


// MARK: - Pay attention, this class use many extensions inside a files not be here.
public class WebRTCClientNew : NSObject , RTCPeerConnectionDelegate , RTCDataChannelDelegate{
    
    static var instance             :WebRTCClientNew?           = nil//for call methods when new message arrive from server
    
    //PeerConnectionFactroies
    private var pcfs                :[String:RTCPeerConnectionFactory] = [:]
    private var peerConnections     :[String:RTCPeerConnection]        = [:]
    
    
    private var config              :WebRTCConfig
    private var delegate            :WebRTCClientDelegate?
    private var localVideoTrack     :RTCVideoTrack?
    private var remoteVideoTrack    :RTCVideoTrack?
    private var videoCapturer       :RTCVideoCapturer?
    private var localDataChannel    :RTCDataChannel?
    private var remoteDataChannel   :RTCDataChannel?
    private var isFrontCamera       :Bool                       = true
    private var videoSource         :RTCVideoSource?
    private var iceQueue            :[(pc:RTCPeerConnection,ice:RTCIceCandidate)] = []
    private var signalingClient     :SignalingClient?
    
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue      = DispatchQueue(label: "audio")
    
    
    var mediaConstraints:[String:[String:String]] = [:]
    
    static let TOPIC_VIDEO_SEND     = [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueFalse, kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueFalse]
    static let TOPIC_VIDEO_RECEIVE  = [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueTrue, kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueFalse]
    static let TOPIC_VOICE_SEND     = [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueFalse,kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueFalse]
    static let TOPIC_VOICE_RECEIVE  = [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueFalse, kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueTrue]
		
    public init(config:WebRTCConfig  , delegate:WebRTCClientDelegate? = nil) {
		self.delegate                       = delegate
		self.config                         = config
        RTCInitializeSSL()
        print(config)
        super.init()
        appendConstraintForTopic(topic: config.topicVideoSend, constraints: WebRTCClientNew.TOPIC_VIDEO_SEND)
        appendConstraintForTopic(topic: config.topicVideoReceive, constraints: WebRTCClientNew.TOPIC_VIDEO_RECEIVE)
        appendConstraintForTopic(topic: config.topicAudioSend, constraints: WebRTCClientNew.TOPIC_VOICE_SEND)
        appendConstraintForTopic(topic: config.topicAudioReceive, constraints: WebRTCClientNew.TOPIC_VOICE_RECEIVE)
        
        createPeerCpnnectionFactoryForTopic(topic: config.topicVideoSend)
        createPeerCpnnectionFactoryForTopic(topic: config.topicVideoReceive)
        createPeerCpnnectionFactoryForTopic(topic: config.topicAudioSend)
        createPeerCpnnectionFactoryForTopic(topic: config.topicAudioReceive)
        
        let rtcConfig                            = RTCConfiguration()
        rtcConfig.sdpSemantics                   = .unifiedPlan
        rtcConfig.continualGatheringPolicy       = .gatherContinually
        rtcConfig.iceServers                     = [RTCIceServer(urlStrings: config.iceServers,username: config.userName!,credential: config.password!)]
        
        createPeerConnection(config.topicVideoSend, rtcConfig: rtcConfig)
        createPeerConnection(config.topicVideoReceive, rtcConfig: rtcConfig)
        createPeerConnection(config.topicAudioSend, rtcConfig: rtcConfig)
        createPeerConnection(config.topicAudioReceive, rtcConfig: rtcConfig)
        createMediaSenders()
        configureAudioSession()
        WebRTCClientNew.instance            = self
        createSession()
    
        // Console output
        RTCSetMinDebugLogLevel(RTCLoggingSeverity.info)

        // File output
//        let path = Bundle.main.bundlePath
//        print("path is\(path)")
//        let logFile = RTCFileLogger(dirPath: path, maxFileSize: 100 * 1024)
//        logFile.severity = .info
//        logFile.start()
	}
    
    func appendConstraintForTopic(topic:String? , constraints:[String:String]){
        if let topic = topic {
            mediaConstraints[topic] = constraints
        }
    }
    
    func createPeerCpnnectionFactoryForTopic(topic:String?){
        if let topic = topic{
            pcfs.updateValue(RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default), forKey: topic)
        }
    }
    
    private func createPeerConnection(_ topic:String? , rtcConfig:RTCConfiguration){
        if let topic = topic,
           let pcf = pcfs[topic],
           let constraints = mediaConstraints[topic],
           let pc = pcf.peerConnection(with: rtcConfig, constraints: .init(mandatoryConstraints: constraints, optionalConstraints: constraints), delegate: nil) {
            pc.delegate     = self
            peerConnections.updateValue(pc, forKey: topic)
        }else{
            print("cant create peerConnection check configration and initialization")
        }
    }
    
    private func createSession(){
        let session = CreateSessionReq(brokerAddress: config.brokerAddress, token: Chat.sharedInstance.token)
        if let data = try? JSONEncoder().encode(session){
            send(data)
        }
    }
	
    private func setConnectedState(peerConnection:RTCPeerConnection){
        print("--- \(getPCName(peerConnection)) connected ---")
        delegate?.didConnectWebRTC()
    }
	
    /** Called when connction state change in RTCPeerConnectionDelegate. */
    private func setDisconnectedState(peerConnection:RTCPeerConnection){
        print("--- \(getPCName(peerConnection)) disconnected ---")
        if let topicName = getTopicForPeerConnection(peerConnection) {
            peerConnections[topicName]?.close()
            peerConnections.removeValue(forKey: topicName)
        }
        self.delegate?.didDisconnectWebRTC()
    }
    
	public func sendMessage(_ message:String){
		sendData(message.data(using: .utf8)!,isBinary: false)
	}
    
    /// Called when connction state change in RTCPeerConnectionDelegate.
    /// - Parameters:
    ///   - data: data to send to peer
    ///   - isBinary: Indicate data is string(UTF-8) or not if you pass true means data in not string and its a stream.
	public func sendData(_ data:Data , isBinary:Bool = true){
		guard let remoteDataChannel = remoteDataChannel else{print("remote data channel is nil"); return}
		remoteDataChannel.sendData(data,isBinary: isBinary)
	}
    
    /// Client can call this to dissconnect from peer.
    public func disconnect(){
        peerConnections.forEach { key,pc in
            pc.close()
        }
	}
    
    public func getLocalSDPWithOffer(topic:String ,onSuccess:@escaping (RTCSessionDescription)->Void){
        guard let mediaConstraint = mediaConstraints[topic] else{return}
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: mediaConstraint, optionalConstraints: nil)
        guard let pp = peerConnections[topic] else{
            print("error peerconection is null")
            return
        }
        pp.offer(for: constraints, completionHandler: { sdp, error in
            error?.printError(message: "error get offer SDP from SDK")
            guard let sdp = sdp else {return}
            pp.setLocalDescription(sdp, completionHandler: { (error) in
                error?.printError(message: "error setLocalDescription for offer")
                onSuccess(sdp)
            })
        })
    }
    
    public func sendOfferToPeer(_ sdp:RTCSessionDescription,topic:String, mediaType:Mediatype){
        let sdp = MakeCustomTextToSend(message: sdp.sdp).replaceSpaceEnterWithSpecificCharecters()
        let sendSDPOffer = SendOfferSDPReq(id: isSendTopic(topic: topic) ? "SEND_SDP_OFFER" : "RECIVE_SDP_OFFER" ,
                                           brokerAddress: config.brokerAddress,
                                           token: Chat.sharedInstance.token,
                                           topic: topic,
                                           sdpOffer: sdp ,
                                           mediaType: mediaType)
        guard let data = try? JSONEncoder().encode(sendSDPOffer) else {
            print("error to encode SDP offer")
            return
        }
        send(data)
    }
    
    public func close(){
        peerConnections.forEach { key , peerConnection in
            peerConnection.close()
        }
        let close = CloseSessionReq(token: Chat.sharedInstance.token)
        guard let data = try? JSONEncoder().encode(close) else {return}
        send(data)
    }
    
    public func send(_ data:Data){
        if let content = String(data: data, encoding: .utf8){
            Chat.sharedInstance.prepareToSendAsync(content,peerName: config.peerName)
        }else{
            print("cant convert data to string")
        }
    }
    
    public func getAnswerSDP(topic:String , onSuccess:@escaping (RTCSessionDescription)->Void){
        guard let mediaConstraint = mediaConstraints[topic] else{return}
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: mediaConstraint, optionalConstraints: nil)
        let pp = peerConnections[topic]
        pp?.answer(for: constraints, completionHandler: { sdp, error in
            error?.printError(message: "error get answer SDP From SDK")
            guard let sdp = sdp else {return}
            pp?.setLocalDescription(sdp, completionHandler: { (error) in
                error?.printError(message: "error setLocalDescription for answer")
                onSuccess(sdp)
            })
        })
    }
    
    private func createMediaSenders(){
        let streamId = "stream"
        
        //Send Audio
        if let audioTrack = createAudioTrack() , let topicAudioSend = config.topicAudioSend {
            peerConnections[topicAudioSend]?.add(audioTrack, streamIds: [streamId])
        }
        
        //Receive Audio
        if let topicAudioReceive = config.topicAudioReceive{
            var error:NSError?
            let transciver = peerConnections[topicAudioReceive]?.addTransceiver(of: .audio)
            transciver?.setDirection(.recvOnly, error: &error)
            if let remoteAudioTrack = transciver?.receiver.track as? RTCAudioTrack {
                peerConnections[topicAudioReceive]?.add(remoteAudioTrack, streamIds: [streamId])
                remoteAudioTrack.isEnabled = true
            }
        }
        
        //Video
        if let topicVideoSend = config.topicVideoSend, let videoTrack   = createVideoTrack(){
            localVideoTrack  = videoTrack
            peerConnections[topicVideoSend]?.add(videoTrack, streamIds: [streamId])
//            peerConnections[config.topicVideoSend]?.setBweMinBitrateBps(80000, currentBitrateBps: 80000, maxBitrateBps: 80000)
        }
        
        if let topicVideoReceive = config.topicVideoReceive{
            var error:NSError?
            let videoReceivetransciver = peerConnections[topicVideoReceive]?.addTransceiver(of: .video)
            videoReceivetransciver?.setDirection(.recvOnly, error: &error)
            if let remoteVideoTrack = videoReceivetransciver?.receiver.track as? RTCVideoTrack{
                peerConnections[topicVideoReceive]?.add(remoteVideoTrack, streamIds: [streamId])
                self.remoteVideoTrack = remoteVideoTrack
            }
        }
    }
    
    private func createVideoTrack()->RTCVideoTrack?{
        guard let topicVideoSend = config.topicVideoSend, let pcfSendVideo = pcfs[topicVideoSend] else {return nil}
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
        guard let topicAudioSend = config.topicAudioSend ,let mediaConstraint = mediaConstraints[topicAudioSend],let pcfAudioSend = pcfs[topicAudioSend] else{return nil}
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints:mediaConstraint, optionalConstraints: nil)
        let audioSource = pcfAudioSend.audioSource(with: audioConstrains)
        let audioTrack = pcfAudioSend.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    private func generateSendKeyFrame(){
        guard let format = getCameraFormat() , let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate else {return}
        let desc = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
        localVideoTrack?.source.adaptOutputFormat(toWidth: desc.width - 5, height: desc.height - 5, fps: Int32(maxFrameRate))
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self]timer in
            guard let self = self else{return}
            self.localVideoTrack?.source.adaptOutputFormat(toWidth: desc.width + 5, height: desc.height + 5, fps: Int32(maxFrameRate))
        }
    }
    
    public func startCaptureLocalVideo(renderer:RTCVideoRenderer , fileName:String){
        if let capturer =  videoCapturer as? RTCCameraVideoCapturer{
            guard let selectedCamera = RTCCameraVideoCapturer.captureDevices().first(where: {$0.position == (isFrontCamera ? .front : .back) }),
                  let format = getCameraFormat(),
                  let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate
            else{return}
            capturer.startCapture(with: selectedCamera, format: format, fps: Int(maxFrameRate))
            localVideoTrack?.add(renderer)
        }else if let capturer = videoCapturer as? RTCFileVideoCapturer{
            capturer.startCapturing(fromFileNamed: fileName , onError: { error in
                error.printError(message: "error on read from mp4 file \(error.localizedDescription)")
            })
            localVideoTrack?.add(renderer)
        }
    }
    
    private func getCameraFormat()->AVCaptureDevice.Format?{
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: {$0.position == (isFrontCamera ? .front : .back) }) else {return nil}
        let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera).last(where: { format in
           CMVideoFormatDescriptionGetDimensions(format.formatDescription).width == 1280 && CMVideoFormatDescriptionGetDimensions(format.formatDescription).height == 720
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
    
    public func renderRemoteVideo(_ renderer:RTCVideoRenderer){
        remoteVideoTrack?.add(renderer)
    }
    
    deinit {
        print("deinit called")
    }
}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCClientNew{
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("\(getPCName(peerConnection))  signaling state changed: \(String(describing: stateChanged.stringValue))")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
		print("\(getPCName(peerConnection)) did add stream")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
		print("\(getPCName(peerConnection)) did remove stream")
	}
	
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
		print("\(getPCName(peerConnection)) should negotiate")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else{ return }
            print("\(self.getPCName(peerConnection)) new connection state: \(String(describing:newState.stringValue))")
            switch newState {
                case .connected, .completed:
                    self.setConnectedState(peerConnection: peerConnection)
            case .closed , .disconnected , .failed :
                self.setDisconnectedState(peerConnection:peerConnection)
                break
            default:
                break
            }
            self.delegate?.didIceConnectionStateChanged(iceConnectionState: newState)
        }
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
		print("\(getPCName(peerConnection)) did change new state")
	}
	
	public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("\(getPCName(peerConnection)) did generate candidate")
        guard let topicName = getTopicForPeerConnection(peerConnection) else{return}
        let sendIceCandidate = SendCandidateReq(token: Chat.sharedInstance.token,
                                                topic: topicName,
                                                candidate: IceCandidate(from: candidate).replaceSpaceSdpIceCandidate)
        guard let data = try? JSONEncoder().encode(sendIceCandidate) else {return}
        self.send(data)
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
		print("\(getPCName(peerConnection)) did remove candidate(s)")
	}
	
	public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
		print("\(getPCName(peerConnection)) did open data channel \(dataChannel)")
		self.remoteDataChannel = dataChannel
	}
    
    private func isSendTopic(topic:String)->Bool{
        return topic == config.topicAudioSend || topic == config.topicVideoSend
    }
    
    private func getPCName(_ peerConnection:RTCPeerConnection)->String{
        guard let topic = getTopicForPeerConnection(peerConnection) else {return ""}
        let isSend  = isSendTopic(topic: topic)
        let isVideo = topic == config.topicVideoSend ||  topic == config.topicVideoReceive
        return "peerConnection\(isSend ? "Send" : "Receive")\(isVideo ? "Video" : "Audio")"
    }
    
    private func getTopicForPeerConnection(_ peerConnection:RTCPeerConnection)->String?{
        if
            let topicVideoSend = config.topicVideoSend, peerConnection == peerConnections[topicVideoSend] { return config.topicVideoSend }
        else
        if let  topicVideoReceive = config.topicVideoReceive, peerConnection == peerConnections[topicVideoReceive] { return config.topicVideoReceive }
        else
        if let topicAudioSend = config.topicAudioSend,  peerConnection == peerConnections[topicAudioSend] { return config.topicAudioSend }
        else
        if let topicAudioReceive = config.topicAudioReceive, peerConnection == peerConnections[topicAudioReceive] { return config.topicAudioReceive }
        else{
            print("topic not found!")
            return nil
        }
    }
    
    public func setCameraIsOn(_ isCameraOn:Bool){
        guard let topicVideoSend = config.topicVideoSend else {return}
        peerConnections[topicVideoSend]?.senders.first?.track?.isEnabled = isCameraOn
    }
    
    public func setMute(_ isMute:Bool){
        guard let topicAudioSend = config.topicAudioSend else {return}
        peerConnections[topicAudioSend]?.senders.first?.track?.isEnabled = !isMute
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
		print("data channel did change state")
		switch dataChannel.readyState {
			case .closed:
				print("closed")
			case .closing:
				print("closing")
			case .connecting:
				print("connecting")
			case .open:
				print("open")
			@unknown default:
				fatalError()
		}
	}
}

//MARK: - OnReceive Message from Async Server
extension WebRTCClientNew{

    func messageReceived(_ message:AsyncMessage){
        guard let data = message.content.data(using: .utf8) ,  let ms = try? JSONDecoder().decode(WebRTCAsyncMessage.self, from: data) else {return}
        print("on Message:\(String(data:data,encoding:.utf8) ?? "")")
        switch ms.id {
        case .SESSION_REFRESH,.CREATE_SESSION:
            Chat.sharedInstance.sotpAllSignalingServerCall(peerName: config.peerName)
            break
        case .ADD_ICE_CANDIDATE:
            addIceToPeerConnection(data)
            break
        case .PROCESS_SDP_ANSWER:
            addSDPAnswerToPeerConnection(data)
            break
        case .GET_KEY_FRAME:
            generateSendKeyFrame()
            break
        case .CLOSE:
            break
        case .STOP_ALL:
            setOffers()
            break
        case .STOP:
            break
        }
    }
    
    func addSDPAnswerToPeerConnection(_ data:Data){
        guard let remoteSDP = try? JSONDecoder().decode(RemoteSDPRes.self, from: data)else{
            print("error in decode PROCESS_SDP_ANSWER: \(String(data: data, encoding: .utf8) ?? "")")
            return
        }
        let pp = peerConnections[remoteSDP.topic]
        pp?.setRemoteDescription(remoteSDP.rtcSDP, completionHandler: { error in
            error?.printError(message: "error in setRemoteDescroptoin with sdp: \(remoteSDP.rtcSDP)")
        })
    }
    
    ///check if remote descriptoin already seted otherwise add it in to queue until set remote description then add ice to peer connection
    func addIceToPeerConnection(_ data:Data){
        guard let candidate = try? JSONDecoder().decode(RemoteCandidateRes.self, from: data) else{
            print("error decode candiadte \(String(data:data, encoding:.utf8) ?? "")")
            return
        }
        guard let pp = peerConnections[candidate.topic] else {
            print("error finding peerConnection\(candidate.topic)")
            return
        }
        let rtcIce = candidate.rtcIceCandidate
        if pp.remoteDescription != nil{
            pp.add(rtcIce, completionHandler: { error in
                error?.printError(message: "\(error.debugDescription) error on add ICE candidiate with :\(candidate.candidate)")
            })
        }else{
            iceQueue.append((pp, rtcIce))
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if pp.remoteDescription != nil{
                    pp.add(rtcIce){ error in
                        error?.printError(message: "\(error.debugDescription) error on add ICE candidiate with :\(rtcIce.sdp)")
                    }
                    self.iceQueue.remove(at: self.iceQueue.firstIndex{ $0.ice == rtcIce}!)
                    print("one ice added to peerconnection from queue and remainig in queu is\(self.iceQueue.count)")
                    timer.invalidate()
                }
            }
        }
    }
}

// configure audio session
extension WebRTCClientNew{
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.rtcAudioSession.setMode(AVAudioSessionModeVoiceChat)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    public func setSpeaker(on:Bool){
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try self.rtcAudioSession.overrideOutputAudioPort(on ? .speaker : .none)
                if on{ try self.rtcAudioSession.setActive(true) }
            } catch let error {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }

}


extension WebRTCClientNew{
    
    public func setOffers(){
        if let topicSendVideo = config.topicVideoSend {
            getOfferAndSendToPeer(topic: topicSendVideo, mediaType: .VIDEO)
        }
        
        if let topicVideoReceive = config.topicVideoReceive {
            getOfferAndSendToPeer(topic: topicVideoReceive, mediaType: .VIDEO)
        }
        
        if let topicAudioSend = config.topicAudioSend {
            getOfferAndSendToPeer(topic: topicAudioSend, mediaType: .AUDIO)
        }
        
        if let topicAudioReceive = config.topicAudioReceive {
            getOfferAndSendToPeer(topic: topicAudioReceive, mediaType: .AUDIO)
        }
    }
    
    func getOfferAndSendToPeer(topic:String,mediaType:Mediatype){
        getLocalSDPWithOffer(topic: topic , onSuccess: { rtcSession in
            self.sendOfferToPeer(rtcSession, topic: topic , mediaType:mediaType )
        })
    }
}
