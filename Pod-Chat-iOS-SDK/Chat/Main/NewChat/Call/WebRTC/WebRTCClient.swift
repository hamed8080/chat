//
//  WebRTCClient.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/8/21.
//

import Foundation
import WebRTC

public protocol WebRTCClientDelegate {
	func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState)
	func didReceiveData(data: Data)
	func didReceiveMessage(message: String)
	func didConnectWebRTC()
	func didDisconnectWebRTC()
}

// MARK: - Pay attention, this class use many extensions inside a files not be here.
public class WebRTCClient : NSObject , RTCPeerConnectionDelegate , RTCDataChannelDelegate ,SignalingClientDelegate{
    
	
	private var peerConnectionFactory :RTCPeerConnectionFactory
	private var peerConnection        :RTCPeerConnection?
	private var config                :WebRTCConfig
	private var delegate              :WebRTCClientDelegate?
    private var signalingClient       :SignalingClient?
    private var localVideoTrack       :RTCVideoTrack?
    private var remoteVideoTrack      :RTCVideoTrack?
    private var videoCapturer         :RTCVideoCapturer?
    private var localDataChannel      :RTCDataChannel?
    private var remoteDataChannel     :RTCDataChannel?
    private var isFrontCamera         :Bool = true
    private let mediaConstrains       :[String:String]       = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                                                kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    
	
	private (set) var isConnected     :Bool = false{
		didSet{
			if isConnected == true{
				setConnectedState()
			}else{
				setDisconnectedState()
			}
		}
	}
		
	public init(config:WebRTCConfig , delegate:WebRTCClientDelegate? = nil) {
		self.delegate                       = delegate
		self.config                         = config
        RTCInitializeSSL()
        self.peerConnectionFactory          = RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default)
        super.init()
        
        let rtcConfig                       = RTCConfiguration()
        rtcConfig.sdpSemantics              = .unifiedPlan
        rtcConfig.continualGatheringPolicy  = .gatherContinually
        rtcConfig.iceServers                = [RTCIceServer(urlStrings: config.iceServers)]
        let constraints                     = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        
        peerConnection                      = peerConnectionFactory.peerConnection(with: rtcConfig, constraints: constraints, delegate: nil)
        signalingClient                     = SignalingClient.connectSocket(socketSignalingAddress: config.socketSignalingAddress, delegate: self)
        createMediaSenders()
        peerConnection?.delegate            = self
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
        
        
        //Data Channel
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
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

// MARK: - SignalingClientDelegate
extension WebRTCClient {
    
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp remoteSDP: RTCSessionDescription) {
        peerConnection?.setRemoteDescription(remoteSDP, completionHandler: { error in })
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        peerConnection?.add(candidate, completionHandler: { error in
            if let error = error {
                print(error)
            }
        })
    }
}
