//
// CMMutualGroup+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public class CMMutualGroup: NSManagedObject {
    @NSManaged public var mutualId: String?
    @NSManaged public var idType: NSNumber?
    @NSManaged public var conversation: CMConversation?
}
