//
// TagProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

@ChatGlobalActor
public protocol TagProtocol: AnyObject {
    /// Get the list of tag participants.
    /// - Parameters:
    ///   - request: The tag id.
    func participants(_ request: GetTagParticipantsRequest)

    /// Remove tag participants from a tag.
    /// - Parameters:
    ///   - request: The tag id and the list of tag participants id.
    func remove(_ request: RemoveTagParticipantsRequest)

    /// Add threads to a tag.
    /// - Parameters:
    ///   - request: The tag id and list of threads id.
    func add(_ request: AddTagParticipantsRequest)

    /// Create a new tag.
    /// - Parameters:
    ///   - request: The name of the tag.
    func create(_ request: CreateTagRequest)

    /// Delete a tag.
    /// - Parameters:
    ///   - request: The id of tag.
    func delete(_ request: DeleteTagRequest)

    /// Edit the tag name.
    /// - Parameters:
    ///   - request: The id of the tag and new name of the tag.
    func edit(_ request: EditTagRequest)

    /// List of Tags.
    func all()
}
