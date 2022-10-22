//
// CMImage+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension CMImage {
    @NSManaged var actualHeight: NSNumber?
    @NSManaged var actualWidth: NSNumber?
    @NSManaged var hashCode: String?
    @NSManaged var height: NSNumber?
    @NSManaged var isThumbnail: NSNumber?
    @NSManaged var name: String?
    @NSManaged var size: NSNumber?
    @NSManaged var width: NSNumber?
}
