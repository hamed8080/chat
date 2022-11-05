//
// RTCVideoRenderer.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import WebRTC
extension RTCVideoRenderer {
    func videoSizeChanged(_ size: CGSize, renderView: RTCEAGLVideoView?) {
        let isLandScape = size.width < size.height
        if let renderView = renderView, let parentView = renderView.superview {
            Chat.sharedInstance.logger?.log(title: "render view video size changed")
            if isLandScape {
                let ratio = size.width / size.height
                renderView.frame = CGRect(x: 0, y: 0, width: parentView.frame.height * ratio, height: parentView.frame.height)
                renderView.center.x = parentView.frame.width / 2
            } else {
                let ratio = size.height / size.width
                renderView.frame = CGRect(x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.width * ratio)
                renderView.center.y = parentView.frame.height / 2
            }
        }
    }
}
