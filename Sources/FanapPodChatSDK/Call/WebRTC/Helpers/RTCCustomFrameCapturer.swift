//
// RTCCustomFrameCapturer.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import WebRTC

class RTCCustomFrameCapturer: RTCVideoCapturer {
    let kNanosecondsPerSecond: Float64 = 1_000_000_000
    var nanoseconds: Float64 = 0

    override init(delegate: RTCVideoCapturerDelegate) {
        super.init(delegate: delegate)
    }

    public func capture(_ sampleBuffer: CMSampleBuffer) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        if let pixelBuffer = pixelBuffer {
            let rtcPixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
            let timeStampNs = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * kNanosecondsPerSecond
            let rtcVideoFrame = RTCVideoFrame(buffer: rtcPixelBuffer, rotation: RTCVideoRotation._90, timeStampNs: Int64(timeStampNs))
            delegate?.capturer(self, didCapture: rtcVideoFrame)
        }
    }

    public func capture(_ pixelBuffer: CVPixelBuffer) {
        let rtcPixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
        let timeStampNs = nanoseconds * kNanosecondsPerSecond

        let rtcVideoFrame = RTCVideoFrame(buffer: rtcPixelBuffer, rotation: RTCVideoRotation._90, timeStampNs: Int64(timeStampNs))
        delegate?.capturer(self, didCapture: rtcVideoFrame)
        nanoseconds += 1
    }
}
