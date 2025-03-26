//
// CDFile+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDFile {
    typealias Entity = CDFile
    typealias Model = File
    typealias Id = String
    static let name = "CDFile"
    static let queryIdSpecifier: String = "%@"
    static let idName = "hashCode"
}

public extension CDFile {
    @NSManaged var hashCode: String?
    @NSManaged var name: String?
    @NSManaged var size: NSNumber?
    @NSManaged var type: String?
}

public extension CDFile {
    func update(_ model: Model) {
        hashCode = model.hashCode ?? hashCode
        name = model.name ?? name
        size = model.size as? NSNumber ?? size
        type = model.type ?? type
    }

    var codable: Model {
        File(hashCode: hashCode, name: name, size: size?.intValue, type: type)
    }
}
