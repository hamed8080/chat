//
//  SignalingClient.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/10/21.
//

import Foundation
import WebRTC

protocol SignalingClientDelegate:AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
    func receiveMeassge(data: Data)
}
class SignalingClient :  WebSocketProviderDelegate {
	
	private var webSocket:WebSocketProvider
    private var decoder                     = JSONDecoder()
    private var encoder                     = JSONEncoder()
    weak var delegate: SignalingClientDelegate?

	init(webSocketProvider:WebSocketProvider) {
		self.webSocket = webSocketProvider
	}

    func connect(){
		webSocket.delegate = self
		webSocket.connect()
	}
    
    public func send(_ rtcSdp:RTCSessionDescription){
        let signalingMessage = SignalingMessage(sdp: SessionDescription(from: rtcSdp))
        guard let data = try? encoder.encode(signalingMessage) else {return}
//        webSocket.send(data: data)
        send(data: data)
    }

    public func send(_ rtcICE:RTCIceCandidate){
        let signalingMessage = SignalingMessage(ice: IceCandidate(from: rtcICE))
        guard let data = try? encoder.encode(signalingMessage) else {return}
//        webSocket.send(data: data)
        send(data: data)
    }
    
    public func send(data:Data){
        if let string = String(data: data, encoding: .utf8){
            print("text send to socket is:\(string)")
            webSocket.send(text: string)
        }
    }
    
	func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        delegate?.signalClientDidConnect(self)
	}

	func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        delegate?.signalClientDidDisconnect(self)
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
	}

	func webSocketDidReciveData(_ webSocket: WebSocketProvider, didReceive data: Data) {
        delegate?.receiveMeassge(data: data)
        let signalingMessage: SignalingMessage
        do {
            signalingMessage = try self.decoder.decode(SignalingMessage.self, from: data)
        }
        catch {
            debugPrint("Warning: Could not decode incoming signalingMessage: \(error)")
            return
        }

        let isSdpType = signalingMessage.sdp != nil

        if isSdpType {
            //sdp type
            print("message received remote sdp")
            guard let remoteSDP = signalingMessage.sdp?.rtcSessionDescription else {return}
            self.delegate?.signalClient(self, didReceiveRemoteSdp: remoteSDP)
        }else if signalingMessage.ice != nil {
            //ice type
            print("did receive remote ice")
            guard let iceCandidate = signalingMessage.ice else{return}
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        }
	}

}
