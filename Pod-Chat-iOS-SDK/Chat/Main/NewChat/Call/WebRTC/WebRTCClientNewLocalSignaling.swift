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
public class WebRTCClientNewLocalSignaling : NSObject , RTCPeerConnectionDelegate , RTCDataChannelDelegate{
    
    
	private var peerConnectionFactory         :RTCPeerConnectionFactory
	private var peerConnection                :RTCPeerConnection?
	private var delegate                      :WebRTCClientDelegate?
    private var localVideoTrack               :RTCVideoTrack?
    private var remoteVideoTrack              :RTCVideoTrack?
    private var videoCapturer                 :RTCVideoCapturer?
    private var localDataChannel              :RTCDataChannel?
    private var remoteDataChannel             :RTCDataChannel?
    private var isFrontCamera                 :Bool = true
    private var remoteVideoRenderer           :RTCVideoRenderer?
    
    private var signalingClient:SignalingClient?
    
    private let mediaConstrains   :[String:String]       = [kRTCMediaConstraintsOfferToReceiveVideo :kRTCMediaConstraintsValueTrue,
                                                                kRTCMediaConstraintsOfferToReceiveAudio :kRTCMediaConstraintsValueTrue]
    
	
	private (set) var isConnected     :Bool = false{
		didSet{
			if isConnected == true{
				setConnectedState()
			}else{
				setDisconnectedState()
			}
		}
	}
		
	public init(delegate:WebRTCClientDelegate? = nil) {
        self.delegate                          = delegate
        RTCInitializeSSL()
        
        self.peerConnectionFactory             = RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory:RTCDefaultVideoDecoderFactory.default)
        super.init()
        
        let rtcConfig                          = RTCConfiguration()
        rtcConfig.sdpSemantics                 = .unifiedPlan
        rtcConfig.continualGatheringPolicy     = .gatherContinually
        let iceServers                         = ["stun:stun.l.google.com:19302",
                                                  "stun:stun1.l.google.com:19302",
                                                  "stun:stun2.l.google.com:19302",
                                                  "stun:stun3.l.google.com:19302",
                                                  "stun:stun4.l.google.com:19302"]
        rtcConfig.iceServers                   = [RTCIceServer(urlStrings: iceServers)]
        let sendConstraints                    = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: mediaConstrains)
        
        peerConnection                         = peerConnectionFactory.peerConnection(with: rtcConfig, constraints: sendConstraints, delegate    : nil)
        peerConnection?.delegate               = self
        createMediaSenders()
        
        
        if #available(iOS 13.0, *) {
            let provider = NativeWebSocketProvider(url: URL(string: "ws://192.168.1.4:8080")!)
            signalingClient = SignalingClient(webSocketProvider: provider)
            signalingClient?.delegate = self
            signalingClient?.connect()
        }else{
            let provider = StarScreamWebSocketProvider(url: URL(string: "ws://192.168.1.4:8080")!)
            signalingClient = SignalingClient(webSocketProvider: provider)
            signalingClient?.delegate = self
            signalingClient?.connect()
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
    
    /// Client can call this to dissconnect from peer.
	public func disconnect(){
		guard let peerConnection = self.peerConnection else{print("peer connection already is nil"); return}
		peerConnection.close()
	}
    
    public func getLocalSDPWithOffer(onSuccess:@escaping (RTCSessionDescription)->Void){
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
    
    public func sendOfferToPeer(_ sdp:RTCSessionDescription){
        signalingClient?.send(sdp)
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
        signalingClient?.send(sdp)
    }
    
    private func createMediaSenders(){
        let streamId = "stream"
        
        //Audio
        let audioTrack = createAudioTrack()
        peerConnection?.add(audioTrack, streamIds: [streamId])
        
        //Video
        let videoTrack   = createVideoTrack()
        localVideoTrack  = videoTrack
        peerConnection?.add(videoTrack, streamIds: [streamId])
        remoteVideoTrack = self.peerConnection?.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
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
    
    public func startCaptureLocalVideo(renderer:RTCVideoRenderer){
        
        guard let capturer = videoCapturer as? RTCCameraVideoCapturer,
        let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: {$0.position == (isFrontCamera ? .front : .back) }),
              let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { (f1, f2) -> Bool in
                  let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                  let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                  return width1 < width2
              }).last,// TODO:- must chose resulation from configVideo
        let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate
        else{return}
        print("selected width is\(CMVideoFormatDescriptionGetDimensions(format.formatDescription).width)")
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
        remoteVideoTrack?.add(renderer)
    }
    
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
        self.peerConnection?.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> ()) {
        self.peerConnection?.add(remoteCandidate, completionHandler: completion)
    }
}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCClientNewLocalSignaling{
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("peerConnection signaling state changed: \(String(describing: stateChanged.stringValue))")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
		print("peerConnection did add stream")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
		print("peerConnection did remove stream")
	}
	
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
		print("peerConnection should negotiate")
	}
	
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("peerConnection new connection state: \(String(describing:newState.stringValue))")
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
        signalingClient?.send(candidate)
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
extension WebRTCClientNewLocalSignaling {
	
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

extension WebRTCClientNewLocalSignaling : SignalingClientDelegate{
   
    
    func signalClientDidConnect(_ signalClient: SignalingClient) {
       setConnectedState()
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        setDisconnectedState()
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        set(remoteSdp: sdp) { (error) in
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        set(remoteCandidate: candidate) { error in
        }
    }
    
    
    func receiveMeassge(data: Data) {
        
    }
    
}
