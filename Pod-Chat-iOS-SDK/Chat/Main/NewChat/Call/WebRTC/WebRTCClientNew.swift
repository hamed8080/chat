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
    
    public static var instance             :WebRTCClientNew?           = nil//for call methods when new message arrive from server
    
    //PeerConnectionFactroies
    private var pcfs                :[String:RTCPeerConnectionFactory] = [:]
    private var peerConnections     :[String:RTCPeerConnection]        = [:]
    private var answerReceived      :[String:RTCPeerConnection]        = [:]
    
    
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
		Chat.sharedInstance.callState = .InitializeWEBRTC
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
        rtcConfig.iceTransportPolicy             = .relay
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
            let encoder = RTCDefaultVideoEncoderFactory.default
            let decoder = RTCDefaultVideoDecoderFactory.default
            pcfs.updateValue(RTCPeerConnectionFactory(encoderFactory: encoder, decoderFactory: decoder), forKey: topic)
        }
    }
    
    private func createPeerConnection(_ topic:String? , rtcConfig:RTCConfiguration){
        if let topic = topic,
           let pcf = pcfs[topic],
           let constraints = mediaConstraints[topic],
           let pc = pcf.peerConnection(with: rtcConfig, constraints: .init(mandatoryConstraints: constraints, optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue]), delegate: nil) {
            pc.delegate     = self
            peerConnections.updateValue(pc, forKey: topic)
        }else{
            customPrint("can't create peerConnection check configration and initialization",isGuardNil: true)
        }
    }
    
    private func createSession(){
        let session = CreateSessionReq(brokerAddress: config.brokerAddress, token: Chat.sharedInstance.token)
        if let data = try? JSONEncoder().encode(session){
            send(data)
        }else{
            customPrint("can't create session decoder was nil",isGuardNil: true)
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
        peerConnections.forEach { key,pc in
            pc.close()
        }
        peerConnections.removeAll()
        let close = CloseSessionReq(token: Chat.sharedInstance.token)
        guard let data = try? JSONEncoder().encode(close) else {
            self.customPrint("error to encode close session request ", isGuardNil: true)
            return
        }
        send(data)
        pcfs.removeAll()
        WebRTCClientNew.instance = nil
	}
    
    public func getLocalSDPWithOffer(topic:String ,onSuccess:@escaping (RTCSessionDescription)->Void){
        guard let mediaConstraint = mediaConstraints[topic] else{
            customPrint("can't find mediaConstraint to get local offer",isGuardNil: true)
            return
        }
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: mediaConstraint, optionalConstraints: nil)
        guard let pp = peerConnections[topic] else{
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
    
    public func sendOfferToPeer(_ sdp:RTCSessionDescription,topic:String, mediaType:Mediatype){
        let sdp = MakeCustomTextToSend(message: sdp.sdp).replaceSpaceEnterWithSpecificCharecters()
        let sendSDPOffer = SendOfferSDPReq(id: isSendTopic(topic: topic) ? "SEND_SDP_OFFER" : "RECIVE_SDP_OFFER" ,
                                           brokerAddress: config.brokerAddress,
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
    
    public func getAnswerSDP(topic:String , onSuccess:@escaping (RTCSessionDescription)->Void){
        guard let mediaConstraint = mediaConstraints[topic] else{return}
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: mediaConstraint, optionalConstraints: nil)
        let pp = peerConnections[topic]
        pp?.answer(for: constraints, completionHandler: { sdp, error in
            if let error = error {
                self.customPrint("error get answer SDP From SDK",error, isGuardNil: true)
            }
            guard let sdp = sdp else {return}
            pp?.setLocalDescription(sdp, completionHandler: { (error) in
                if let error = error{
                    self.customPrint("error setLocalDescription for answer",error, isGuardNil: true)
                }
                onSuccess(sdp)
            })
        })
    }
    
    private func createMediaSenders(){
        //Send Audio
        if let audioTrack = createAudioTrack() , let topicAudioSend = config.topicAudioSend {
            peerConnections[topicAudioSend]?.add(audioTrack, streamIds: [config.topicAudioSend ?? ""])
        }
        
        //Receive Audio
        if let topicAudioReceive = config.topicAudioReceive{
            var error:NSError?
            let transciver = peerConnections[topicAudioReceive]?.addTransceiver(of: .audio)
            transciver?.setDirection(.recvOnly, error: &error)
            if let remoteAudioTrack = transciver?.receiver.track as? RTCAudioTrack {
                peerConnections[topicAudioReceive]?.add(remoteAudioTrack, streamIds: [config.topicAudioReceive ?? ""])
                remoteAudioTrack.isEnabled = true
            }
        }
        
        //Video
        if let topicVideoSend = config.topicVideoSend, let videoTrack   = createVideoTrack(){
            localVideoTrack  = videoTrack
            peerConnections[topicVideoSend]?.add(videoTrack, streamIds: [config.topicVideoSend ?? ""])
//            peerConnections[config.topicVideoSend]?.setBweMinBitrateBps(80000, currentBitrateBps: 80000, maxBitrateBps: 80000)
        }
        
        if let topicVideoReceive = config.topicVideoReceive{
            var error:NSError?
			let videoReceivetransciver = peerConnections[topicVideoReceive]?.addTransceiver(of: .video)
            videoReceivetransciver?.setDirection(.recvOnly, error: &error)
            if let remoteVideoTrack = videoReceivetransciver?.receiver.track as? RTCVideoTrack{
                peerConnections[topicVideoReceive]?.add(remoteVideoTrack, streamIds: [config.topicVideoReceive ?? ""])
                self.remoteVideoTrack = remoteVideoTrack
            }
        }
    }
    
    private func createVideoTrack()->RTCVideoTrack?{
        guard let topicVideoSend = config.topicVideoSend, let pcfSendVideo = pcfs[topicVideoSend] else {
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
        guard let topicAudioSend = config.topicAudioSend ,let mediaConstraint = mediaConstraints[topicAudioSend],let pcfAudioSend = pcfs[topicAudioSend] else{
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
        localVideoTrack?.source.adaptOutputFormat(toWidth: 1280 + 50, height: 720, fps: Int32(15))
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self]timer in
            guard let self = self else{
                self?.customPrint("self was nil in timer generate keyFrame!",isGuardNil:true)
                return
            }
            DispatchQueue.main.async {
                self.customPrint("resize to normal generate key frame")
//                self.localVideoTrack?.isEnabled = true
                self.localVideoTrack?.source.adaptOutputFormat(toWidth: 1280, height: 720, fps: Int32(15))
            }
        }
    }
    
    public func startCaptureLocalVideo(renderer:RTCVideoRenderer , fileName:String){
        if let capturer =  videoCapturer as? RTCCameraVideoCapturer{
            guard let selectedCamera = RTCCameraVideoCapturer.captureDevices().first(where: {$0.position == (isFrontCamera ? .front : .back) }),
                  let format = getCameraFormat(),
                  let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate
            else{
                self.customPrint("error happend to startCaptureLocalVideo",isGuardNil:true)
                return
            }
            capturer.startCapture(with: selectedCamera, format: format, fps: Int(maxFrameRate))
            localVideoTrack?.add(renderer)
        }else if let capturer = videoCapturer as? RTCFileVideoCapturer{
            capturer.startCapturing(fromFileNamed: fileName , onError: { error in
                self.customPrint("error on read from mp4 file" , error,isGuardNil:true)
            })
            localVideoTrack?.add(renderer)
        }
    }
    
    private func getCameraFormat()->AVCaptureDevice.Format?{
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: {$0.position == (isFrontCamera ? .front : .back) }) else {
            self.customPrint("error to find front camera" ,isGuardNil:true)
            return nil
        }
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
    
    var renderer:RTCVideoRenderer?
    public func renderRemoteVideo(_ renderer:RTCVideoRenderer){
        self.renderer = renderer
        remoteVideoTrack?.add(renderer)
    }
    
    deinit {
        customPrint("deinit webrtc client called")
    }
    
    func customPrint(_ message:String , _ error:Error? = nil , isSuccess:Bool = false ,isGuardNil:Bool = false){
        let errorMessage = error != nil ? " with error:\(error?.localizedDescription ?? "")" : ""
        let icon = isGuardNil ? "❌" : isSuccess ? "✅" : ""
        print("\(icon) \(message) \(errorMessage)")
    }
}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCClientNew{
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        customPrint("\(getPCName(peerConnection))  signaling state changed: \(String(describing: stateChanged.stringValue))")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        customPrint("\(getPCName(peerConnection)) did add stream")
		if let videoTrack = stream.videoTracks.first,
		   let renderer = renderer,
		   let topicReceiveVideo = config.topicVideoReceive,
		   peerConnection == peerConnections[topicReceiveVideo]
		{
            customPrint("\(getPCName(peerConnection)) did add stream video track")
			videoTrack.add(renderer)
		}
        
        if let audioTrack = stream.audioTracks.first,
           let topicReceiveAudio = config.topicAudioReceive,
           peerConnection == peerConnections[topicReceiveAudio]
        {
            customPrint("\(getPCName(peerConnection)) did add stream audio track")
            peerConnection.add(audioTrack, streamIds: [topicReceiveAudio])
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
                if  self.peerConnections[topicName]?.remoteDescription != nil{
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
            customPrint("topic not found!",isGuardNil: true)
            return nil
        }
    }
    
    public func setCameraIsOn(_ isCameraOn:Bool){
        guard let topicVideoSend = config.topicVideoSend else {
            customPrint("topicVideoSend was nil! setCameraIsOn not working!",isGuardNil: true)
            return
        }
        peerConnections[topicVideoSend]?.senders.first?.track?.isEnabled = isCameraOn
    }
    
    public func setMute(_ isMute:Bool){
        guard let topicAudioSend = config.topicAudioSend else {
            customPrint("topicAudioSend was nil! setMute not working!",isGuardNil: true)
            return
        }
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
        customPrint("data channel did changeed state to \(dataChannel.readyState)")
	}
}

//MARK: - OnReceive Message from Async Server
extension WebRTCClientNew{

    func messageReceived(_ message:AsyncMessage){
        guard let data = message.content.data(using: .utf8) ,  let ms = try? JSONDecoder().decode(WebRTCAsyncMessage.self, from: data) else {
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
//            var count:Double = 0
//            Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { timer in
//
//                if count < 5{
//                    self.generateSendKeyFrame()
//                }else{
//                    timer.invalidate()
//                    return
//                }
//                count  = count + 1
//            }
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
			let pp = self.peerConnections[remoteSDP.topic]
			pp?.statistics(completionHandler: { report in
			})
			pp?.setRemoteDescription(remoteSDP.rtcSDP, completionHandler: { error in
				if let error = error{
					self.customPrint("error in setRemoteDescroptoin with sdp: \(remoteSDP.rtcSDP)",error,isGuardNil: true)
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
		guard let pp = peerConnections[candidate.topic] else {
			self.customPrint("error finding topic or peerconnection",isGuardNil: true)
			return
		}
		let rtcIce = candidate.rtcIceCandidate
		if pp.remoteDescription != nil{
			setRemoteIceOnMainThread(pp, rtcIce)
		}else{
			iceQueue.append((pp, rtcIce))
			Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] timer in
				guard let self = self else {return}
				if pp.remoteDescription != nil{
					self.setRemoteIceOnMainThread(pp, rtcIce)
					self.iceQueue.remove(at: self.iceQueue.firstIndex{ $0.ice == rtcIce}!)
					self.customPrint("ICE added to peerconnection from queue and remainig in queu is\(self.iceQueue.count)")
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
    
    func reconnectAndGetOffer(_ peerConnection:RTCPeerConnection){
        guard let topic = getTopicForPeerConnection(peerConnection)else{
            customPrint("can't find topic to reconnect peerconnection",isGuardNil: true)
            return
        }
        customPrint("restart to get new SDP and send offer")
        let mediaType:Mediatype = topic == config.topicVideoSend ||  topic == config.topicVideoReceive ? .VIDEO : .AUDIO
        self.getOfferAndSendToPeer(topic: topic, mediaType: mediaType)
    }
}
