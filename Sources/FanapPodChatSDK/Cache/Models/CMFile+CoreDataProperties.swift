//
// CMFile+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public extension CMFile {
    @NSManaged var hashCode: String?
    @NSManaged var name: String?
    @NSManaged var size: NSNumber?
    @NSManaged var type: String?
}
