//
//  WebRTCClient.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/8/21.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate {
	func didGenerateCandidate(iceCandidate: RTCIceCandidate)
	func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState)
	func didReceiveData(data: Data)
	func didReceiveMessage(message: String)
	func didConnectWebRTC()
	func didDisconnectWebRTC()
}

// MARK: - Pay attention, this class use many extensions inside a files not be here.
class WebRTCClient : NSObject , RTCPeerConnectionDelegate , RTCVideoViewDelegate, RTCDataChannelDelegate{
	
	private var peerConnectionFactory :RTCPeerConnectionFactory
	private var peerConnection        :RTCPeerConnection?
	private var config                :WebRTCConfig
	private var delegate              :WebRTCClientDelegate?
	private var remoteDataChannel     :RTCDataChannel?
	private var remoteMediaStream     :RTCMediaStream?
	
	private (set) var isConnected     :Bool = false{
		didSet{
			if isConnected == true{
				setConnectedState()
			}else{
				setDisconnectedState()
			}
		}
	}
	
	private (set) var renderViews:[RTCEAGLVideoView] = []
	
	init(config:WebRTCConfig , delegate:WebRTCClientDelegate? = nil) {
		self.delegate = delegate
		self.config = config
		self.peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default)
	}
	
	private func setupViewForVideoConference(){
		
		if let localFrame = config.videoConfig?.localVideoViewFrame {
			createRenderViewAndAddSubview(frame: localFrame)
		}
		
		if let remoteFrame = config.videoConfig?.remoteVideoViewFrame {
			createRenderViewAndAddSubview(frame: remoteFrame)
		}
	}
	
	private func createRenderViewAndAddSubview(frame:CGRect){
		let renderView =  RTCEAGLVideoView()
		let view = UIView()
		view.frame = frame
		renderView.delegate = self
		view.addSubview(renderView)
		renderViews.append(renderView)
	}
	
	private func setConnectedState(){
		DispatchQueue.main.async {
			print("--- on connected ---")
			self.renderViews.forEach{ $0.isHidden = false}
			self.delegate?.didConnectWebRTC()
		}
	}
	
	private func setDisconnectedState(){
		self.isConnected = false
		DispatchQueue.main.async {
			print("--- on dis connected ---")
			self.peerConnection!.close()
			self.peerConnection = nil
			self.renderViews.forEach{$0.isHidden = true}
//			self.dataChannel = nil
			self.delegate?.didDisconnectWebRTC()
		}
	}
	
	public func sendMessage(_ message:String){
		sendData(message.data(using: .utf8)!,isBinary: false)
	}
	
	public func sendData(_ data:Data , isBinary:Bool = true){
		guard let remoteDataChannel = remoteDataChannel else{print("remote data channel is nil"); return}
		remoteDataChannel.sendData(data,isBinary: isBinary)
	}
	
	public func disconnect(){
		guard let peerConnection = self.peerConnection else{print("peer connection already is nil"); return}
		peerConnection.close()
	}
}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCClient{
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
		print("signaling state changed: \(String(describing: stateChanged))")
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
		print("peerConnection did add stream")
		remoteMediaStream = stream
		
		if let track = stream.videoTracks.first , let remoteRenderView = renderViews.last {
			print("video track found")
			track.add(remoteRenderView)
		}
		
		if let audioTrack = stream.audioTracks.first{
			print("audio track found")
			audioTrack.source.volume = 8
		}
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
		print("peerConnection did remove stream")
	}
	
	func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
		print("peerConnection should negotiate")
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
		print("peerConnection new connection state: \(newState)")
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
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
		print("peerConnection did change new state")
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
		print("peerConnection did generate candidate")
		delegate?.didGenerateCandidate(iceCandidate: candidate)
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
		print("peerConnection did remove candidate(s)")
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
		print("peerConnection did open data channel \(dataChannel)")
		self.remoteDataChannel = dataChannel
	}
}

// MARK: - RTCVideoViewDelegate
extension WebRTCClient{
	
	func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
		videoView.videoSizeChanged(size , renderView: renderViews.first(where: { $0.isEqual(videoView) }))
	}
}


// MARK: - RTCDataChannelDelegate
extension WebRTCClient {
	
	func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
		DispatchQueue.main.async {
			if buffer.isBinary {
				self.delegate?.didReceiveData(data: buffer.data)
			}else {
				self.delegate?.didReceiveMessage(message: String(data: buffer.data, encoding: String.Encoding.utf8)!)
			}
		}
	}

	func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
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
