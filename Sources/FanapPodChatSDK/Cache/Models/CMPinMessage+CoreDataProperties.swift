//
// CMPinMessage+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension CMPinMessage {
    @NSManaged var messageId: NSNumber?
    @NSManaged var text: String?
    @NSManaged var notifyAll: NSNumber?
    @NSManaged var message: CMMessage?
}
