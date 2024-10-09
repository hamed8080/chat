//
// LocationMessageRequest+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

extension LocationMessageRequest {

    public func imageRequest(data: Data, wC: Int, hC: Int, mimeType: String = "image/png") -> UploadImageRequest {
        UploadImageRequest(data: data,
                           fileExtension: "png",
                           fileName: "\(mapImageName ?? "").png",
                           mimeType: mimeType,
                           userGroupHash: userGroupHash,
                           uniqueId: uniqueId,
                           hC: hC,
                           wC: wC)
    }

    public var textMessageRequest: SendTextMessageRequest {
        SendTextMessageRequest(threadId: threadId,
                               textMessage: textMessage ?? "",
                               messageType: .podSpacePicture,
                               repliedTo: repliedTo,
                               systemMetadata: systemMetadata,
                               uniqueId: uniqueId)
    }
}
