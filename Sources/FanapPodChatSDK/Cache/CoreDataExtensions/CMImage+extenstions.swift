//
// CMImage+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension CMImage {
    static let crud = CoreDataCrud<CMImage>(entityName: "CMImage")

    func getCodable() -> ImageModel? {
        guard let hashCode = hashCode else { return nil }
        return ImageModel(actualHeight: actualHeight as? Int,
                          actualWidth: actualWidth as? Int,
                          hashCode: hashCode,
                          height: height as? Int,
                          name: name ?? "",
                          size: size as? Int,
                          width: width as? Int)
    }

    class func convertToCM(request: ImageModel, isThumbnail: Bool, entity: CMImage? = nil) -> CMImage {
        let model = entity ?? CMImage()
        model.actualHeight = request.actualHeight as NSNumber?
        model.actualWidth = request.actualWidth as NSNumber?
        model.hashCode = request.hashCode
        model.height = request.height as NSNumber?
        model.isThumbnail = NSNumber(value: isThumbnail)
        model.name = request.name
        model.size = request.size as NSNumber?
        model.width = request.width as NSNumber?

        return model
    }

    class func insert(request: ImageModel, isThumbnail: Bool, resultEntity: ((CMImage) -> Void)? = nil) {
        CMImage.crud.insert { cmEntity in
            let cmEntity = convertToCM(request: request, isThumbnail: isThumbnail, entity: cmEntity)
            resultEntity?(cmEntity)
        }
    }
}
