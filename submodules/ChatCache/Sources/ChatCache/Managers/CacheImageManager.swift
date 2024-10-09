//
// CacheImageManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheImageManager: BaseCoreDataManager<CDImage> {
    public func first(hashCode: String, completion: @escaping ((Entity.Model?) -> Void)) {
        firstOnMain(with: hashCode, context: viewContext) { image in
            let image = image?.codable
            completion(image)
        }
    }
}
