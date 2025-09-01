//
// ReactionManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import Async

extension CallManager {
    func onReceivedMessage(_ message: AsyncMessage) {
        guard let content = message.content, let data = content.data(using: .utf8), let ms = try? JSONDecoder().decode(CallAsyncMessage.self, from: data) else {
            return
        }
        do {
            switch ms.id {
            case .sessionRefresh, .createSession, .sessionNewCreated:
                let resp = try JSONDecoder.instance.decode(CreateSessionResp.self, from: data)
                onSessionCreated(resp)
            case .receivingMedia:
                let receivingMedia = try JSONDecoder.instance.decode(ReceivingMedia.self, from: data)
                subscribeToReceivingOffers(receivingMedia)
            case .addIceCandidate:
                let candidate = try JSONDecoder().decode(RemoteCandidateRes.self, from: data)
                processRemoteIceCandidate(candidate)
            case .processSdpAnswer:
                let res = try JSONDecoder().decode(RemoteSDPAnswerRes.self, from: data)
                processSDPAnswer(res)
            case .processSdpOffer:
                let res = try JSONDecoder().decode(RemoteSDPOfferRes.self, from: data)
                processSDPOffer(res)
            case .receiveSdpAnswer:
                break
            case .processSdpUpdate:
                break
            case .getKeyFrame:
                break
            case .close:
                break
            case .stopAll:
                //                setOffers()
                break
            case .stop:
                break
            case .receiveSdpOffer, .sendSdpOffer, .sdpAnswerReceived:
                break
            case .error:
                break
            case .freezed:
                break
            case .recieveMetadata:
                let metadata = try JSONDecoder.instance.decode(ReceiveCallMetadata.self, from: data)
                processReceiveMetadata(metadata)
            case .sendIceCandidate:
                let res = try JSONDecoder.instance.decode(SendCandidateRes.self, from: data)
                onSendIceCandidate(res)
            case .receiveAddIceCandidate:
                break
            case .prcessSdpNegotiate:
                break
            case .processLatestSdpOffer:
                break
            case .sendMetadata:
                break
            case .requestReceivingMedia:
                break
            case .joinAdditionComplete:
                break
            case .joinDeletionComplete:
                break
            case .subscriptionFailed:
                break
            case .updateFailed:
                break
            case .releaseResources:
                break
            case .slowLink:
                break
            case .exitClient:
                break
            case .sendComplete:
                break
            case .unpublished:
                break
            case .subscribe:
                break
            case .update:
                break
            case .unkown:
                log("An unkown message has been received with id: decoded type in it's content in CallManager: " + (message.content ?? ""))
            }
        } catch {
            log("Failed to decode Call Server with error: \(error.localizedDescription) for Message: " + (message.content ?? ""))
        }
    }
}
