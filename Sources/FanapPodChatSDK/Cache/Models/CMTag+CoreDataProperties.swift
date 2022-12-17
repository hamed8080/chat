//
// CMTag+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public extension CMTag {
    @NSManaged var id: NSNumber?
    @NSManaged var name: String
    @NSManaged var owner: CMParticipant
    @NSManaged var active: NSNumber
    @NSManaged var tagParticipants: Set<CMTagParticipant>?
}
