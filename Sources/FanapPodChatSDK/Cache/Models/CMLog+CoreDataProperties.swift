//
// CMLog+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension CMLog {
    @NSManaged var id: String?
    @NSManaged var json: String?
    @NSManaged var time: NSNumber?
}
