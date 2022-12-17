//
// CMAssistant+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public extension CMAssistant {
    @NSManaged var inviteeId: NSNumber? // inviteeId == participant.Id
    @NSManaged var contactType: String?
    @NSManaged var assistant: NSData?
    @NSManaged var participant: CMParticipant?
    @NSManaged var roles: [String]?
    @NSManaged var block: NSNumber
}
