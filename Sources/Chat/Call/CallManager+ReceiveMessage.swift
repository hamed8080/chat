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
                //                stopAllSessions()
                break
            case .receivingMedia:
                let receivingMedia = try JSONDecoder.instance.decode(ReceivingMedia.self, from: data)
                subscribeToReceivingOffers(receivingMedia)
            case .addIceCandidate:
                let candidate = try JSONDecoder().decode(RemoteCandidateRes.self, from: data)
                processRemoteIceCandidate(candidate)
            case .processSdpAnswer:
                let res = try JSONDecoder().decode(RemoteSDPRes.self, from: data)
                processSDPAnswer(res)
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
            case .receiveSdpOffer:
                break
            case .sendSdpOffer:
                break
            case .error:
                break
            case .freezed:
                break
            case .recieveMetadata:
                break
            case .sdpAnswerReceived:
                break
            case .unkown:
                log("An unkown message has been received with id: decoded type in it's content in CallManager: " + (message.content ?? ""))
            }
        } catch {
            log("Failed to decode Call Server Message: " + (message.content ?? ""))
        }
    }
}
