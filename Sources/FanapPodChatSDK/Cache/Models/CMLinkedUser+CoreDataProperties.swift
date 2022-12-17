//
// CMLinkedUser+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public extension CMLinkedUser {
    @NSManaged var coreUserId: NSNumber?
    @NSManaged var image: String?
    @NSManaged var name: String?
    @NSManaged var nickname: String?
    @NSManaged var username: String?
    @NSManaged var dummyContact: CMContact?
}
