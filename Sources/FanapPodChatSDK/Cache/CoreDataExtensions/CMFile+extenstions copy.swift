//
// CMFile+extenstions copy.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public extension CMFile {
    static let crud = CoreDataCrud<CMFile>(entityName: "CMFile")

    func getCodable() -> FileModel? {
        guard let hashCode = hashCode else { return nil }
        return FileModel(hashCode: hashCode, name: name, size: size as? Int, type: type)
    }

    class func convertToCM(request: FileModel, entity: CMFile? = nil) -> CMFile {
        let model = entity ?? CMFile()
        model.hashCode = request.hashCode
        model.name = request.name
        model.size = request.size as NSNumber?
        model.type = request.type

        return model
    }

    class func insert(request: FileModel, resultEntity: ((CMFile) -> Void)? = nil) {
        CMFile.crud.insert { cmEntity in
            let cmEntity = convertToCM(request: request, entity: cmEntity)
            resultEntity?(cmEntity)
        }
    }
}
