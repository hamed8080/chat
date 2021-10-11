//
//  WebRTCClient.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/8/21.
//

import Foundation
import WebRTC
import FanapPodAsyncSDK

public protocol WebRTCClientDelegate {
	func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState)
	func didReceiveData(data: Data)
	func didReceiveMessage(message: String)
	func didConnectWebRTC()
	func didDisconnectWebRTC()
}

// MARK: - Pay attention, this class use many extensions inside a files not be here.
public class WebRTCClient : NSObject , RTCPeerConnectionDelegate , RTCDataChannelDelegate{
    
    static var instance:WebRTCClient? = nil//for call methods when new message arrive from server
    
	private var peerConnectionFactory :RTCPeerConnectionFactory
	private var peerConnection        :RTCPeerConnection?
	private var config                :WebRTCConfigOld
	private var delegate              :WebRTCClientDelegate?
    private var localVideoTrack       :RTCVideoTrack?
    private var remoteVideoTrack      :RTCVideoTrack?
    private var videoCapturer         :RTCVideoCapturer?
    private var localDataChannel      :RTCDataChannel?
    private var remoteDataChannel     :RTCDataChannel?
    private var isFrontCamera         :Bool = true
    private var remoteVideoRenderer   :RTCVideoRenderer?
//    private let mediaConstrains       :[String:String]       = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
//                                                                kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    
    private let mediaConstrains       :[String:String]       = [kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue ,
                                                                kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueFalse]
    
	
	private (set) var isConnected     :Bool = false{
		didSet{
			if isConnected == true{
				setConnectedState()
			}else{
				setDisconnectedState()
			}
		}
	}
		
	public init(config:WebRTCConfigOld , delegate:WebRTCClientDelegate? = nil) {
		self.delegate                       = delegate
		self.config                         = config
        RTCInitializeSSL()
        self.peerConnectionFactory          = RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default)
        super.init()
        
        let rtcConfig                       = RTCConfiguration()
        rtcConfig.sdpSemantics              = .unifiedPlan
        rtcConfig.continualGatheringPolicy  = .gatherContinually
        rtcConfig.iceServers                = [RTCIceServer(urlStrings: config.iceServers,username: config.userName,credential: config.password)]
        let constraints                     = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        
        peerConnection                      = peerConnectionFactory.peerConnection(with: rtcConfig, constraints: constraints, delegate: nil)
        createMediaSenders()
        peerConnection?.delegate            = self
        createSession()
        WebRTCClient.instance               = self
	}
    
    private func createSession(){
        let session = CreateSessionReq(turnAddress: "", brokerAddress: config.brokerAddress, token: Chat.sharedInstance.token)
        if let data = try? JSONEncoder().encode(session){
            send(data)
        }
    }
	
	private func setConnectedState(){
		DispatchQueue.main.async {
			print("--- on connected ---")
			self.delegate?.didConnectWebRTC()
		}
	}
	
    /** Called when connction state change in RTCPeerConnectionDelegate. */
	private func setDisconnectedState(){
		DispatchQueue.main.async {
            self.isConnected = false
			print("--- on dis connected ---")
			self.peerConnection?.close()
			self.peerConnection = nil
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
		guard let peerConnection = self.peerConnection else{print("peer connection already is nil"); return}
		peerConnection.close()
	}
    
    public func getLocalSDPWithOffer(isSend:Bool,onSuccess:@escaping (RTCSessionDescription)->Void){
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        peerConnection?.offer(for: constraints, completionHandler: { sdp, error in
            if let error = error{
                print("error make offer\(error.localizedDescription)")
                return
            }
            
            guard let sdp = sdp else {return}
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { (error) in
                onSuccess(sdp)
            })
        })
    }
    
    public func sendOfferToPeer(_ sdp:RTCSessionDescription,isSend:Bool){
        // FIXME: - Fix topic to dynamic and mediaType and Topic
        let sdp = MakeCustomTextToSend(message: sdp.sdp).replaceSpaceEnterWithSpecificCharecters()
        let sendSDPOffer = SendOfferSDPReq(id: isSend ? "SEND_SDP_OFFER" : "RECIVE_SDP_OFFER" ,
                                           brokerAddress: config.brokerAddress,
                                           token: Chat.sharedInstance.token,
                                           topic: isSend ? config.topicVideoSend : config.topicVideoReceive,
                                           sdpOffer: sdp ,
                                           mediaType: .VIDEO)
        guard let data = try? JSONEncoder().encode(sendSDPOffer) else {return}
        send(data) // signaling server - peerConnection
    }
    
    public func send(_ data:Data){
        if let content = String(data: data, encoding: .utf8){
            Chat.sharedInstance.prepareToSendAsync(content,peerName: config.peerName)
        }
    }
    
    public func getAnswerSDP(onSuccess:@escaping (RTCSessionDescription)->Void){
        let constraints = RTCMediaConstraints.init(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        peerConnection?.answer(for: constraints, completionHandler: { sdp, error in
            if let error = error{
                print("error make offer\(error.localizedDescription)")
                return
            }
            
            guard let sdp = sdp else {return}
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { (error) in
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
        
        //Audio
//        let audioTrack = createAudioTrack()
//        peerConnection?.add(audioTrack, streamIds: [streamId])
        
        //Video
        let videoTrack   = createVideoTrack()
        localVideoTrack  = videoTrack
        peerConnection?.add(videoTrack, streamIds: [streamId])
        remoteVideoTrack = self.peerConnection?.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
        
        
        //Data Channel
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
    }
    
    public func closeSignalingServerCall(){
        let close = CloseSessionReq(token: Chat.sharedInstance.token)
        guard let data = try? JSONEncoder().encode(close) else {return}
        send(data)
    }
    
    private func createVideoTrack()->RTCVideoTrack{
        let videoSource = peerConnectionFactory.videoSource()
            
        #if targetEnvironment(simulator)
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    private func createAudioTrack()->RTCAudioTrack{
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = peerConnectionFactory.audioSource(with: audioConstrains)
        let audioTrack = peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    private func createDataChannel()->RTCDataChannel?{
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = peerConnection?.dataChannel(forLabel: "WebRTCData", configuration: config) else{
            print("warning: Couldn't create data channel")
            return nil
        }
        return dataChannel
    }
    
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
extension WebRTCClient{
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
		print("signaling state changed: \(String(describing: stateChanged))")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
		print("peerConnection did add stream")
//        if let track = stream.videoTracks.first , let renderer = remoteVideoRenderer {
//            print("video track faund")
//            track.add(renderer)
//        }
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
		print("peerConnection did remove stream")
	}
	
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
		print("peerConnection should negotiate")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("peerConnection new connection state: \(String(describing:newState))")
		switch newState {
			case .connected, .completed:
				if !self.isConnected {
					self.isConnected.toggle()
				}
			default:
				if self.isConnected{
					self.isConnected.toggle()
				}
		}
		DispatchQueue.main.async {
			self.delegate?.didIceConnectionStateChanged(iceConnectionState: newState)
		}
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
		print("peerConnection did change new state")
	}
	
	public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
		print("peerConnection did generate candidate")
        // FIXME: - Fix topic to dynamic
        let sendIceCandidate = SendCandidateReq(id: "ADD_ICE_CANDIDATE", token: Chat.sharedInstance.token, topic: config.topicVideoSend, candidate: IceCandidate(from: candidate))
        guard let data = try? JSONEncoder().encode(sendIceCandidate) else {return}
        send(data)
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
		print("peerConnection did remove candidate(s)")
	}
	
	public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
		print("peerConnection did open data channel \(dataChannel)")
		self.remoteDataChannel = dataChannel
	}
}

// MARK: - RTCDataChannelDelegate
extension WebRTCClient {
	
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
extension WebRTCClient{
    
    func messageReceived(_ message:AsyncMessage){
        guard let data = message.content.data(using: .utf8) ,  let ms = try? JSONDecoder().decode(WebRTCAsyncMessage.self, from: data) else {return}
        switch ms.id {
        case .SESSION_REFRESH,.CREATE_SESSION:
            //nothing to do for now
            break
        case .ADD_ICE_CANDIDATE:
            guard let candidate = try? JSONDecoder().decode(RemoteCandidateRes.self, from: data) else {return}
            peerConnection?.add(candidate.rtcIceCandidate, completionHandler: { error in
                if let error = error {
                    print(error)
                }
            })
            break
        case .PROCESS_SDP_ANSWER:
            guard let remoteSDP = try? JSONDecoder().decode(RemoteSDPRes.self, from: data) else{return}
            peerConnection?.setRemoteDescription(remoteSDP.rtcSDP, completionHandler: { error in })
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
        print( "call on Message\n:" +  String(data: data, encoding: .utf8)!)
    }
}

enum WebRTCMessageType:String,Decodable {
    case CREATE_SESSION      = "CREATE_SESSION"
    case SESSION_NEW_CREATED = "SESSION_NEW_CREATED"
    case SESSION_REFRESH     = "SESSION_REFRESH"
    case GET_KEY_FRAME       = "GET_KEY_FRAME"
    case ADD_ICE_CANDIDATE   = "ADD_ICE_CANDIDATE"
    case PROCESS_SDP_ANSWER  = "PROCESS_SDP_ANSWER"
    case CLOSE               = "CLOSE"
    case STOP_ALL            = "STOPALL"
    case STOP                = "STOP"
    case UNKOWN
    
    //prevent crash when new case added from server side
    public init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(String.self) else{
            self = .UNKOWN
            return
        }
        self = WebRTCMessageType(rawValue: value) ?? .UNKOWN
    }
}
struct WebRTCAsyncMessage:Decodable {
    let id:WebRTCMessageType
}
