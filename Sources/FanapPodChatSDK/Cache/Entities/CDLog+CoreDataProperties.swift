//
//  CDLog+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDLog {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDLog> {
        NSFetchRequest<CDLog>(entityName: "CDLog")
    }

    @NSManaged var config: Data?
    @NSManaged var deviceInfo: Data?
    @NSManaged var id: String?
    @NSManaged var level: NSNumber?
    @NSManaged var message: String?
    @NSManaged var time: NSNumber?
}

public extension CDLog {
    func update(_ log: Log) {
        config = log.config?.toData()
        deviceInfo = log.deviceInfo?.toData()
        id = log.id.uuidString
        level = log.level?.rawValue as? NSNumber
        message = log.message
        time = log.time?.timeIntervalSince1970 as? NSNumber
    }

    var codable: Log {
        Log(time: Date(timeIntervalSince1970: (time ?? 0).doubleValue),
            message: message,
            config: try? JSONDecoder().decode(ChatConfig.self, from: config ?? Data()),
            deviceInfo: try? JSONDecoder().decode(DeviceInfo.self, from: deviceInfo ?? Data()),
            level: LogLevel(rawValue: level?.intValue ?? 0),
            id: UUID(uuidString: id ?? "") ?? UUID())
    }
}
