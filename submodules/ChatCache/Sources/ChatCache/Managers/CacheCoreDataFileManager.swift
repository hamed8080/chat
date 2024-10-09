//
// CacheCoreDataFileManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheCoreDataFileManager: BaseCoreDataManager<CDFile> {
    public func first(hashCode: String, completion: @escaping ((Entity.Model?) -> Void)) {
        firstOnMain(with: hashCode, context: viewContext) { file in
            let file = file?.codable
            completion(file)
        }
    }
}
