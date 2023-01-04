//
// CMLog+extenions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

internal extension CMLog {
    static let crud = CoreDataCrud<CMLog>(entityName: "CMLog")

    func getCodable() -> Log? {
        try? JSONDecoder().decode(Log.self, from: json?.data(using: .utf8) ?? Data())
    }

    class func convertToCM(log: Log, entity: CMLog? = nil) -> CMLog {
        let model = entity ?? CMLog()
        model.id = log.id
        model.json = String(data: (try? JSONEncoder().encode(log)) ?? Data(), encoding: .utf8)
        model.time = log.time as NSNumber
        return model
    }

    class func insertOrUpdate(log: Log, resultEntity: ((CMLog) -> Void)? = nil) {
        CMLog.crud.insert { entity in
            let cmLog = convertToCM(log: log, entity: entity)
            resultEntity?(cmLog)
        }
    }
}
