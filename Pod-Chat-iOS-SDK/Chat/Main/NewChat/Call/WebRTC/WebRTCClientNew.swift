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
    private var remoteVideoRenderer :RTCVideoRenderer?
    
    private var signalingClient     :SignalingClient?
    
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    
    
    private lazy var mediaConstarints:[String:[String:String]] =
        [
            config.topicVideoSend : [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueFalse,
                                     kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueFalse],
            
            config.topicVideoReceive : [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueTrue,
                                        kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueFalse],
            
            config.topicAudioSend : [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueFalse,
                                     kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueFalse],
            
            config.topicAudioReceive : [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueFalse,
                                        kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueTrue]
        ]
		
    public init(config:WebRTCConfig  , delegate:WebRTCClientDelegate? = nil) {
		self.delegate                       = delegate
		self.config                         = config
        print(config)
        RTCInitializeSSL()
        
        self.pcfs.updateValue(RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default), forKey: config.topicVideoSend)
        self.pcfs.updateValue(RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default), forKey: config.topicVideoReceive)
        self.pcfs.updateValue(RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default), forKey: config.topicAudioSend)
        self.pcfs.updateValue(RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default), forKey: config.topicAudioReceive)
        
        super.init()
        
        let rtcConfig                            = RTCConfiguration()
        rtcConfig.sdpSemantics                   = .unifiedPlan
        rtcConfig.continualGatheringPolicy       = .gatherContinually
        rtcConfig.iceServers                     = [RTCIceServer(urlStrings: config.iceServers,username: config.userName!,credential: config.password!)]
        let sendVideoConstraints                 = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: mediaConstarints[config.topicVideoSend])
        let receiveVideoConstraints              = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: mediaConstarints[config.topicVideoReceive])
        
        let sendAudioConstraints                 = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: mediaConstarints[config.topicAudioSend])
        let receiveAudioConstraints              = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: mediaConstarints[config.topicAudioReceive])
        
        createPeerConnection(config.topicVideoSend, rtcConfig: rtcConfig, constraints: sendVideoConstraints)
        createPeerConnection(config.topicVideoReceive, rtcConfig: rtcConfig, constraints: receiveVideoConstraints)
        createPeerConnection(config.topicAudioSend, rtcConfig: rtcConfig, constraints: sendAudioConstraints)
        createPeerConnection(config.topicAudioReceive, rtcConfig: rtcConfig, constraints: receiveAudioConstraints)
        createMediaSenders()
        configureAudioSession()
        WebRTCClientNew.instance            = self
        createSession()
	}
    
    private func createPeerConnection(_ topic:String , rtcConfig:RTCConfiguration , constraints:RTCMediaConstraints){
        if let pcf = pcfs[topic],let pc = pcf.peerConnection(with: rtcConfig, constraints: constraints, delegate: nil) {
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
        peerConnections[getTopicForPeerConnection(peerConnection)]?.close()
        peerConnections.removeValue(forKey: getTopicForPeerConnection(peerConnection))
        // self.dataChannel = nil
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
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: mediaConstarints[topic]!, optionalConstraints: nil)
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
    
    public func send(_ data:Data){
        if let content = String(data: data, encoding: .utf8){
            Chat.sharedInstance.prepareToSendAsync(content,peerName: config.peerName)
        }else{
            print("cant convert data to string")
        }
    }
    
    public func getAnswerSDP(topic:String , onSuccess:@escaping (RTCSessionDescription)->Void){
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: mediaConstarints[topic]!, optionalConstraints: nil)
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
    
    public func sendAnswerToPeer(_ sdp:RTCSessionDescription){
        // FIXME: - Fix topic to dynamic and mediaType and Topic
        let sendSDPOffer = SendOfferSDPReq(id: "SEND_SDP_OFFER", brokerAddress: config.brokerAddress, token: Chat.sharedInstance.token, topic: config.topicVideoReceive, sdpOffer: sdp.sdp , mediaType: .VIDEO)
        guard let data = try? JSONEncoder().encode(sendSDPOffer) else {return}
        send(data)
    }
    
    private func createMediaSenders(){
        let streamId = "stream"
        
        //Send Audio
        if let audioTrack = createAudioTrack(){
            peerConnections[config.topicAudioSend]?.add(audioTrack, streamIds: [streamId])
        }
        
        //Receive Audio
        var error:NSError?
        let transciver = peerConnections[config.topicAudioReceive]?.addTransceiver(of: .audio)
        transciver?.setDirection(.recvOnly, error: &error)
        if let remoteAudioTrack = transciver?.receiver.track as? RTCAudioTrack {
            peerConnections[config.topicAudioReceive]?.add(remoteAudioTrack, streamIds: [streamId])
            remoteAudioTrack.isEnabled = true
        }
        
        //Video
        if let videoTrack   = createVideoTrack(){
            localVideoTrack  = videoTrack
//            peerConnections[config.topicVideoReceive]?.add(videoTrack, streamIds: [streamId])
            peerConnections[config.topicVideoSend]?.add(videoTrack, streamIds: [streamId])
        }
//        let transceiver = peerConnectionSend?.addTransceiver(with: videoTrack)
//        var error:NSError?
//        transceiver?.setDirection(.sendOnly, error: &error)
        let videoReceivetransciver = peerConnections[config.topicVideoReceive]?.addTransceiver(of: .video)
        videoReceivetransciver?.setDirection(.recvOnly, error: &error)
        if let remoteVideoTrack = videoReceivetransciver?.receiver.track as? RTCVideoTrack{
            peerConnections[config.topicVideoReceive]?.add(remoteVideoTrack, streamIds: [streamId])
            self.remoteVideoTrack = remoteVideoTrack
        }
        
//        remoteVideoTrack = peerConnections[config.topicVideoReceive]?.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
       
        
        
        //Data Channel
//        if let dataChannel = createDataChannel() {
//            dataChannel.delegate = self
//            self.localDataChannel = dataChannel
//        }
    }
    
    private func createVideoTrack()->RTCVideoTrack?{
        guard let pcfSendVideo = pcfs[config.topicVideoSend] else {return nil}
        let videoSource = pcfSendVideo.videoSource()
        #if targetEnvironment(simulator)
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = pcfSendVideo.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    private func createAudioTrack()->RTCAudioTrack?{
        guard let pcfAudioSend = pcfs[config.topicAudioSend] else{return nil}
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: mediaConstarints[config.topicAudioSend], optionalConstraints: nil)
        let audioSource = pcfAudioSend.audioSource(with: audioConstrains)
        let audioTrack = pcfAudioSend.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
//    private func createDataChannel()->RTCDataChannel?{
//        let config = RTCDataChannelConfiguration()
//        guard let dataChannel = peerConnectionSend?.dataChannel(forLabel: "WebRTCData", configuration: config) else{
//            print("warning: Couldn't create data channel")
//            return nil
//        }
//        return dataChannel
//    }
    
    public func startCaptureLocalVideo(renderer:RTCVideoRenderer){
        
        guard let capturer = videoCapturer as? RTCCameraVideoCapturer,
        let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: {$0.position == (isFrontCamera ? .front : .back) }),
        let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera).last(where: { format in
           let width =  CMVideoFormatDescriptionGetDimensions(format.formatDescription).width == 1280
           let height =  CMVideoFormatDescriptionGetDimensions(format.formatDescription).height == 720
            return width && height
        }),// TODO:- must chose resulation from configVideo
        let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate
        else{return}
        
        capturer.startCapture(with: frontCamera, format: format, fps: Int(maxFrameRate))
        localVideoTrack?.add(renderer)
    }
    
    public func switchCameraPosition(renderer:RTCVideoRenderer){
        if let capturer = videoCapturer as? RTCCameraVideoCapturer{
            capturer.stopCapture {
                self.isFrontCamera.toggle()
                self.startCaptureLocalVideo(renderer:renderer)
            }
        }
    }
    
    public func renderRemoteVideo(_ renderer:RTCVideoRenderer){
//        remoteVideoRenderer = renderer
        remoteVideoTrack?.add(renderer)
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
        let sendIceCandidate = SendCandidateReq(token: Chat.sharedInstance.token,
                                                topic: getTopicForPeerConnection(peerConnection),
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
        let topic   = getTopicForPeerConnection(peerConnection)
        let isSend  = isSendTopic(topic: topic)
        let isVideo = topic == config.topicVideoSend ||  topic == config.topicVideoReceive
        return "peerConnection\(isSend ? "Send" : "Receive")\(isVideo ? "Video" : "Audio")"
    }
    
    private func getTopicForPeerConnection(_ peerConnection:RTCPeerConnection)->String{
        if peerConnection == peerConnections[config.topicVideoSend] { return config.topicVideoSend }
        else if peerConnection == peerConnections[config.topicVideoReceive] { return config.topicVideoReceive }
        else if peerConnection == peerConnections[config.topicAudioSend] { return config.topicAudioSend }
        else if peerConnection == peerConnections[config.topicAudioReceive] { return config.topicAudioReceive }
        return "NotFindPeerName"
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
            do{
                let candidate = try JSONDecoder().decode(RemoteCandidateRes.self, from: data)
                let pp = peerConnections[candidate.topic]
                pp?.add(candidate.rtcIceCandidate, completionHandler: { error in
                    error?.printError(message: "error on add ICE candidiate with :\(candidate.candidate)")
                })
            }catch{
                error.printError(message: "error decode ICE JSON")
            }
            break
        case .PROCESS_SDP_ANSWER:
            do{
                let remoteSDP = try JSONDecoder().decode(RemoteSDPRes.self, from: data)
                let pp = peerConnections[remoteSDP.topic]
                pp?.setRemoteDescription(remoteSDP.rtcSDP, completionHandler: { error in
                    error?.printError(message: "error in setRemoteDescroptoin with sdp: \(remoteSDP.rtcSDP)")
                })
            }catch{
                error.printError(message: "error in decode PROCESS_SDP_ANSWER")
            }
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
        getLocalSDPWithOffer(topic: config.topicVideoSend , onSuccess: { rtcSession in
            self.sendOfferToPeer(rtcSession, topic: self.config.topicVideoSend, mediaType: .VIDEO)
        })
        
        getLocalSDPWithOffer(topic: config.topicVideoReceive , onSuccess: { rtcSession in
            self.sendOfferToPeer(rtcSession, topic: self.config.topicVideoReceive, mediaType: .AUDIO)
        })
        
        getLocalSDPWithOffer(topic: config.topicAudioSend , onSuccess: { rtcSession in
            self.sendOfferToPeer(rtcSession, topic: self.config.topicAudioSend, mediaType: .AUDIO)
        })
        
        getLocalSDPWithOffer(topic: config.topicAudioReceive , onSuccess: { rtcSession in
            self.sendOfferToPeer(rtcSession, topic: self.config.topicAudioReceive, mediaType: .AUDIO)
        })
    }
    
}
