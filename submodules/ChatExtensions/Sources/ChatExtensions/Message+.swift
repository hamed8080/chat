//
// Message+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels
import ChatDTO

public extension Message {
    // FIXME: need fix with object decoding in this calss with FileMetaData for proerty metadata
    var fileMetaData: FileMetaData? {
        guard let metadata = metadata?.data(using: .utf8),
              let metaData = try? JSONDecoder.instance.decode(FileMetaData.self, from: metadata) else { return nil }
        return metaData
    }
    
    var addRemoveParticipant: AddRemoveParticipant? {
        guard messageType == .participantJoin || messageType == .participantLeft,
              let metadata = metadata?.data(using: .utf8) else { return nil }
        return try? JSONDecoder.instance.decode(AddRemoveParticipant.self, from: metadata)
    }
}
