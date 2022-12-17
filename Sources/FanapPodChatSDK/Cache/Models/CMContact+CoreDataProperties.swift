//
// CMContact+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public extension CMContact {
    @NSManaged var blocked: NSNumber?
    @NSManaged var cellphoneNumber: String?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var hasUser: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var image: String?
    @NSManaged var lastName: String?
    @NSManaged var notSeenDuration: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var uniqueId: String?
    @NSManaged var userId: NSNumber?
    @NSManaged var linkedUser: CMLinkedUser?
}
