//
//  Log+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class Log: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        id = try container?.decodeIfPresent(String.self, forKey: .id)
        message = try container?.decodeIfPresent(String.self, forKey: .message)
        let config = try? container?.decodeIfPresent(ChatConfig.self, forKey: .config)
        self.config = try? JSONEncoder().encode(config)
        let deviceInfo = try? container?.decodeIfPresent(DeviceInfo.self, forKey: .deviceInfo)
        self.deviceInfo = try? JSONEncoder().encode(deviceInfo)
        time = try container?.decodeIfPresent(Int.self, forKey: .time) as? NSNumber
        level = try container?.decodeIfPresent(Int.self, forKey: .level) as? NSNumber
    }
}

public extension Log {
    private enum CodingKeys: String, CodingKey {
        case time
        case level
        case message
        case id
        case config
        case deviceInfo
    }

    convenience init(
        context: NSManagedObjectContext,
        time: Date = Date(),
        message: String? = nil,
        config: ChatConfig? = nil,
        deviceInfo: DeviceInfo? = nil,
        level: LogLevel? = nil,
        id: UUID = UUID()
    ) {
        self.init(context: context)
        self.time = (time.timeIntervalSince1970) as NSNumber
        self.message = message
        self.id = id.string
        self.config = try? JSONEncoder().encode(config)
        self.deviceInfo = try? JSONEncoder().encode(deviceInfo)
        self.level = level?.rawValue as? NSNumber
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(time as? Int, forKey: .time)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(message, forKey: .message)
        let deviceInfo = try? JSONDecoder().decode(DeviceInfo.self, from: deviceInfo ?? Data())
        try container.encodeIfPresent(deviceInfo, forKey: .deviceInfo)
        let config = try? JSONDecoder().decode(ChatConfig.self, from: config ?? Data())
        try container.encodeIfPresent(config, forKey: .config)
        try container.encodeIfPresent(level?.intValue, forKey: .level)
    }
}

// internal extension CMLog {
//    static let crud = CoreDataCrud<CMLog>(entityName: "CMLog")
//
//    func getCodable() -> Log? {
//        try? JSONDecoder().decode(Log.self, from: json?.data(using: .utf8) ?? Data())
//    }
//
//    class func convertToCM(log: Log, entity: CMLog? = nil) -> CMLog {
//        let model = entity ?? CMLog()
//        model.id = log.id
//        model.json = String(data: (try? JSONEncoder().encode(log)) ?? Data(), encoding: .utf8)
//        model.time = log.time as NSNumber
//        return model
//    }
// }
