//
// CacheCoreDataFileManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheCoreDataFileManager: BaseCoreDataManager<CDFile>, @unchecked Sendable {
    @MainActor
    public func first(hashCode: String) -> Entity.Model? {
        return first(with: hashCode)?.codable
    }
}
