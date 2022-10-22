//
// CMUser+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension CMUser {
    @NSManaged var cellphoneNumber: String?
    @NSManaged var contactSynced: NSNumber?
    @NSManaged var coreUserId: NSNumber?
    @NSManaged var email: String?
    @NSManaged var id: NSNumber?
    @NSManaged var image: String?
    @NSManaged var lastSeen: NSNumber?
    @NSManaged var name: String?
    @NSManaged var receiveEnable: NSNumber?
    @NSManaged var sendEnable: NSNumber?
    @NSManaged var username: String?
    @NSManaged var ssoId: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?

    @NSManaged var bio: String?
    @NSManaged var metadata: String?
}
