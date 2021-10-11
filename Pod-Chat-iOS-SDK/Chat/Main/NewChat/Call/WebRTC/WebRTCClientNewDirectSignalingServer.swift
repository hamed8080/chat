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
public class WebRTCClientNewDirectServer : NSObject , RTCPeerConnectionDelegate , RTCDataChannelDelegate{
    
	private var peerConnectionFactorySend     :RTCPeerConnectionFactory
    private var peerConnectionFactoryReceive  :RTCPeerConnectionFactory
	private var peerConnectionSend            :RTCPeerConnection?
    private var peerConnectionReceive         :RTCPeerConnection?
	private var config                        :WebRTCConfigOld
	private var delegate                      :WebRTCClientDelegate?
    private var localVideoTrack               :RTCVideoTrack?
    private var remoteVideoTrack              :RTCVideoTrack?
    private var videoCapturer                 :RTCVideoCapturer?
    private var localDataChannel              :RTCDataChannel?
    private var remoteDataChannel             :RTCDataChannel?
    private var isFrontCamera                 :Bool = true
    private var remoteVideoRenderer           :RTCVideoRenderer?
    
    private var signalingClient:SignalingClient?
    
    private let sendMediaConstrains   :[String:String]       = [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueFalse,
                                                                kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueFalse]
    
    private let receviceMediaConstrains   :[String:String]       = [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueTrue,
                                                                kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueFalse]
        
	private (set) var isSendPeerConnected   :Bool = false{
		didSet{
			if isSendPeerConnected == true{
				setConnectedState(isSend: true)
			}else{
				setDisconnectedState(isSend: true)
			}
		}
	}
    
    private (set) var isReceivePeerConnected   :Bool = false{
        didSet{
            if isReceivePeerConnected == true{
                setConnectedState(isSend: false)
            }else{
                setDisconnectedState(isSend: false)
            }
        }
    }
		
	public init(config:WebRTCConfigOld , delegate:WebRTCClientDelegate? = nil) {
		self.delegate                       = delegate
		self.config                         = config
        RTCInitializeSSL()
        
        self.peerConnectionFactorySend      = RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default)
        self.peerConnectionFactoryReceive   = RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default)
        super.init()
        
        let rtcConfig                       = RTCConfiguration()
        rtcConfig.sdpSemantics              = .unifiedPlan
        rtcConfig.continualGatheringPolicy  = .gatherContinually
        rtcConfig.iceServers                = [RTCIceServer(urlStrings: config.iceServers,username: config.userName,credential: config.password)]
        let sendConstraints                 = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: sendMediaConstrains)
        let receiveConstraints              = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: receviceMediaConstrains)
        
        peerConnectionSend                  = peerConnectionFactorySend.peerConnection(with: rtcConfig, constraints: sendConstraints, delegate: nil)
        peerConnectionReceive               = peerConnectionFactoryReceive.peerConnection(with: rtcConfig, constraints: receiveConstraints, delegate: nil)
        createMediaSenders()
        peerConnectionSend?.delegate        = self
        peerConnectionReceive?.delegate     = self
        connectToSocket()
        
	}
    
    private func createSession(){
        let session = CreateSessionReq(turnAddress: "", brokerAddress: config.brokerAddress, token: Chat.sharedInstance.token)
        if let data = try? JSONEncoder().encode(session){
            signalingClient?.send(data: data)
        }
    }
    
    private func connectToSocket(){
//        if #available(iOS 13.0, *) {
//            let provider = NativeWebSocketProvider(url: URL(string: "wss://188.75.65.159/gsthandler")!)
//            signalingClient = SignalingClient(webSocketProvider: provider)
//            signalingClient?.delegate = self
//            signalingClient?.connect()
//        }else{
//            let provider = StarScreamWebSocketProvider(url: URL(string: "wss://188.75.65.159/gsthandler")!)
//            signalingClient = SignalingClient(webSocketProvider: provider)
//            signalingClient?.delegate = self
//            signalingClient?.connect()
//        }
//
        let provider = StarScreamWebSocketProvider(url: URL(string: "wss://188.75.65.159/gsthandler")!)
        signalingClient = SignalingClient(webSocketProvider: provider)
        signalingClient?.delegate = self
        signalingClient?.connect()
    }
	
    private func setConnectedState(isSend:Bool){
		DispatchQueue.main.async {
            print("--- on connected\(isSend ? "Send"  : "Receive") ---")
			self.delegate?.didConnectWebRTC()
		}
	}
	
    /** Called when connction state change in RTCPeerConnectionDelegate. */
    private func setDisconnectedState(isSend:Bool){
		DispatchQueue.main.async {
            print("--- on peerConnection\(isSend ? "Send" : "Receive") disconnected ---")
            if isSend{
                self.isSendPeerConnected = false
                self.peerConnectionSend?.close()
                self.peerConnectionSend = nil
            }else{
                self.isReceivePeerConnected = false
                self.peerConnectionReceive?.close()
                self.peerConnectionReceive  = nil
            }
//			self.dataChannel = nil
			self.delegate?.didDisconnectWebRTC()
		}
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
		guard let peerConnection = self.peerConnectionSend else{print("peer connection already is nil"); return}
		peerConnection.close()
	}
    
    public func getLocalSDPWithOffer(isSend:Bool,onSuccess:@escaping (RTCSessionDescription)->Void){
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: isSend ? sendMediaConstrains : receviceMediaConstrains, optionalConstraints: nil)
        let pp = isSend ? peerConnectionSend : peerConnectionReceive
        pp?.offer(for: constraints, completionHandler: { sdp, error in
            if let error = error{
                print("error make offer\(error.localizedDescription)")
                return
            }
            guard let sdp = sdp else {return}
            pp?.setLocalDescription(sdp, completionHandler: { (error) in
                onSuccess(sdp)
            })
        })
    }
    
    public func sendOfferToPeer(_ sdp:RTCSessionDescription,isSend:Bool){
        // FIXME: - Fix topic to dynamic and mediaType and Topic
        let sendSDPOffer = SendOfferSDPReq(id: isSend ? "SEND_SDP_OFFER" : "RECIVE_SDP_OFFER" ,
                                           brokerAddress: config.brokerAddress,
                                           token: Chat.sharedInstance.token,
                                           topic: isSend ? config.topicVideoSend : config.topicVideoReceive,
                                           sdpOffer: sdp.sdp ,
                                           mediaType: .VIDEO)
        guard let data = try? JSONEncoder().encode(sendSDPOffer) else {return}
        signalingClient?.send(data:data)
    }

    
    public func getAnswerSDP(onSuccess:@escaping (RTCSessionDescription)->Void){
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: sendMediaConstrains, optionalConstraints: nil)
//        peerConnectionSend?.answer(for: constraints, completionHandler: { sdp, error in
//            if let error = error{
//                print("error make offer\(error.localizedDescription)")
//                return
//            }
//
//            guard let sdp = sdp else {return}
//            self.peerConnectionSend?.setLocalDescription(sdp, completionHandler: { (error) in
//                onSuccess(sdp)
//            })
//        })
    }
    
    public func sendAnswerToPeer(_ sdp:RTCSessionDescription){
        // FIXME: - Fix topic to dynamic and mediaType and Topic
        let sendSDPOffer = SendOfferSDPReq(id: "SEND_SDP_OFFER", brokerAddress: config.brokerAddress, token: Chat.sharedInstance.token, topic: config.topicVideoReceive, sdpOffer: sdp.sdp , mediaType: .VIDEO)
        guard let data = try? JSONEncoder().encode(sendSDPOffer) else {return}
        signalingClient?.send(data:data)
    }
    
    private func createMediaSenders(){
        let streamId = "stream"
        
        //Audio
//        let audioTrack = createAudioTrack()
//        peerConnection?.add(audioTrack, streamIds: [streamId])
        
        //Video
        let videoTrack   = createVideoTrack()
        localVideoTrack  = videoTrack
        peerConnectionReceive?.add(videoTrack, streamIds: [streamId])
        peerConnectionSend?.add(videoTrack, streamIds: [streamId])
//        let transceiver = peerConnectionSend?.addTransceiver(with: videoTrack)
//        var error:NSError?
//        transceiver?.setDirection(.sendOnly, error: &error)
        remoteVideoTrack = self.peerConnectionReceive?.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
        
        
        //Data Channel
//        if let dataChannel = createDataChannel() {
//            dataChannel.delegate = self
//            self.localDataChannel = dataChannel
//        }
    }
    
    private func createVideoTrack()->RTCVideoTrack{
        let videoSource = peerConnectionFactorySend.videoSource()
            
        #if targetEnvironment(simulator)
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = peerConnectionFactorySend.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    private func createAudioTrack()->RTCAudioTrack{
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = peerConnectionFactorySend.audioSource(with: audioConstrains)
        let audioTrack = peerConnectionFactorySend.audioTrack(with: audioSource, trackId: "audio0")
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
           let width =  CMVideoFormatDescriptionGetDimensions(format.formatDescription).width == 1920
           let height =  CMVideoFormatDescriptionGetDimensions(format.formatDescription).height == 1080
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
extension WebRTCClientNewDirectServer{
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("peerConnection\(peerConnection == peerConnectionSend ? "Send" : "Receive")  signaling state changed: \(String(describing: stateChanged.stringValue))")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
		print("peerConnection\(peerConnection == peerConnectionSend ? "Send" : "Receive") did add stream")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
		print("peerConnection\(peerConnection == peerConnectionSend ? "Send" : "Receive") did remove stream")
	}
	
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
		print("peerConnection\(peerConnection == peerConnectionSend ? "Send" : "Receive") should negotiate")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("peerConnection\(peerConnection == peerConnectionSend ? "Send" : "Receive") new connection state: \(String(describing:newState.stringValue))")
        let isSend = peerConnection  == peerConnectionSend
        if isSend{
            switch newState {
                case .connected, .completed:
                    if !self.isSendPeerConnected {
                        self.isSendPeerConnected.toggle()
                    }
                default:
                    if self.isSendPeerConnected{
                        self.isSendPeerConnected.toggle()
                    }
            }
            DispatchQueue.main.async {
                self.delegate?.didIceConnectionStateChanged(iceConnectionState: newState)
            }
        }else{
            switch newState {
                case .connected, .completed:
                    if !self.isReceivePeerConnected {
                        self.isReceivePeerConnected.toggle()
                    }
                default:
                    if self.isReceivePeerConnected{
                        self.isReceivePeerConnected.toggle()
                    }
            }
            DispatchQueue.main.async {
                self.delegate?.didIceConnectionStateChanged(iceConnectionState: newState)
            }
        }
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
		print("peerConnection\(peerConnection == peerConnectionSend ? "Send" : "Receive") did change new state")
	}
	
	public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("peerConnection\(peerConnection == peerConnectionSend ? "Send" : "Receive") did generate candidate")
        let isSend = peerConnection == peerConnectionSend
        let sendIceCandidate = SendCandidateReq(id: "ADD_ICE_CANDIDATE", token: Chat.sharedInstance.token, topic: isSend ? config.topicVideoSend :  config.topicVideoReceive , candidate: IceCandidate(from: candidate))
        guard let data = try? JSONEncoder().encode(sendIceCandidate) else {return}
        signalingClient?.send(data:data)
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
		print("peerConnection\(peerConnection == peerConnectionSend ? "Send" : "Receive") did remove candidate(s)")
	}
	
	public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
		print("peerConnection\(peerConnection == peerConnectionSend ? "Send" : "Receive") did open data channel \(dataChannel)")
		self.remoteDataChannel = dataChannel
	}
}

// MARK: - RTCDataChannelDelegate
extension WebRTCClientNewDirectServer {
	
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

extension WebRTCClientNewDirectServer : SignalingClientDelegate{
    func receiveMeassge(data: Data) {
        
        print("on Message:\(String(data:data,encoding:.utf8) ?? "")")
        guard let ms = try? JSONDecoder().decode(WebRTCAsyncMessage.self, from: data) else {return}
        switch ms.id {
        case .SESSION_REFRESH,.CREATE_SESSION:
            let close = StopAllSessionReq(token: Chat.sharedInstance.token)
            guard let data = try? JSONEncoder().encode(close) else {return}
            signalingClient?.send(data: data)
            break
        case .ADD_ICE_CANDIDATE:
            guard let candidate = try? JSONDecoder().decode(RemoteCandidateRes.self, from: data) else {return}
            let pp = candidate.topic == config.topicVideoSend ? peerConnectionSend : peerConnectionReceive
            pp?.add(candidate.rtcIceCandidate, completionHandler: { error in
                if let error = error {
                    print(error)
                }
            })
            break
        case .PROCESS_SDP_ANSWER:
            guard let remoteSDP = try? JSONDecoder().decode(RemoteSDPRes.self, from: data) else{return}
            let pp = remoteSDP.topic == config.topicVideoSend ? peerConnectionSend : peerConnectionReceive
            pp?.setRemoteDescription(remoteSDP.rtcSDP, completionHandler: { error in })
            break
        case .CLOSE:
            break
        case .GET_KEY_FRAME:
            break        
        case .STOP_ALL:
            break
        case .STOP:
            break
        case .SESSION_NEW_CREATED:
            break
        case .UNKOWN:
            break
        }
    }
    
    
    func signalClientDidConnect(_ signalClient: SignalingClient) {
     createSession()
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        
    }
    
}
