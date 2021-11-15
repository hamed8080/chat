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
public class WebRTCClientNewCheckTurn : NSObject , RTCPeerConnectionDelegate , RTCDataChannelDelegate{



    //PeerConnectionFactroies
    private var peerConnectionFactory      :RTCPeerConnectionFactory
    private var peerConnection             :RTCPeerConnection? = nil


    private var delegate            :WebRTCClientDelegate?
    private var localDataChannel    :RTCDataChannel?
    private var remoteDataChannel   :RTCDataChannel?
    private var signalingClient     :SignalingClient?
    
    
    private (set) var isConnected     :Bool = false{
        didSet{
            if isConnected == true{
                setConnectedState()
            }else{
                setDisconnectedState()
            }
        }
    }


    public override init() {
        peerConnectionFactory = RTCPeerConnectionFactory()
        let constaint = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        
        let rtcConfig                            = RTCConfiguration()
        rtcConfig.sdpSemantics                   = .unifiedPlan
        rtcConfig.iceTransportPolicy             = .relay
        rtcConfig.continualGatheringPolicy       = .gatherContinually
        rtcConfig.iceServers                     = [RTCIceServer(urlStrings: ["turn:46.32.6.188?transport=udp"],username: "mkhorrami",credential: "mkh_123456")]
        peerConnection = peerConnectionFactory.peerConnection(with: rtcConfig, constraints: constaint , delegate: nil)
        
        super.init()
        
        self.peerConnection?.delegate    = self
        RTCSetMinDebugLogLevel(RTCLoggingSeverity.info)
        createDataChannel()
        createOffer()
        
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
            Chat.sharedInstance.logger?.log(title: "--- on connected ---")
            self.delegate?.didConnectWebRTC()
        }
    }
    
    /** Called when connction state change in RTCPeerConnectionDelegate. */
    private func setDisconnectedState(){
        DispatchQueue.main.async {
            self.isConnected = false
            Chat.sharedInstance.logger?.log(title: "--- on dis connected ---")
            self.peerConnection?.close()
            self.peerConnection = nil
//            self.dataChannel = nil
            self.delegate?.didDisconnectWebRTC()
        }
    }

    private func createDataChannel(){
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = peerConnection?.dataChannel(forLabel: "WebRTCData", configuration: config) else{
            Chat.sharedInstance.logger?.log(title: "warning: Couldn't create data channel")
            return
        }
        dataChannel.sendData("test".data(using: .utf8) ??  Data())
    }
    
    private func createOffer(){
        peerConnection?.offer(for: .init(mandatoryConstraints: nil, optionalConstraints: nil), completionHandler: { sdp, error in
            error?.printError(message: "error in genreate sdp offer")
            if let sdp = sdp{
                Chat.sharedInstance.logger?.log(title: "generated sdp offer is\(sdp.sdp)")
                self.peerConnection?.setLocalDescription(sdp, completionHandler: { error in
                    error?.printError(message: "error to set sdp to local description")
                })
            }
        })
    }
    
    
    public func sendAnswerToPeer(_ sdp:RTCSessionDescription){
        signalingClient?.send(sdp)
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
    }

    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {

    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        Chat.sharedInstance.logger?.log(title: "connection state changed to \(newState.stringValue)")
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        if candidate.sdp.contains("typ relay"){
            Chat.sharedInstance.logger?.log(title: "connected to turn ice:\(candidate.sdp)")
        }else{
            Chat.sharedInstance.logger?.log(title: "can't connect to turn ice:\(candidate.sdp)")
        }
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        Chat.sharedInstance.logger?.log(title: "did open data channel \(dataChannel)")
        self.remoteDataChannel = dataChannel
    }

    public func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        Chat.sharedInstance.logger?.log(title: "data channel state \(dataChannel.readyState)")
    }

    public func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {

    }
    
    
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
        self.peerConnection?.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> ()) {
        self.peerConnection?.add(remoteCandidate, completionHandler: completion)
    }
}


extension WebRTCClientNewCheckTurn : SignalingClientDelegate{
   
    
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
