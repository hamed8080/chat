//
// CacheImageManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheImageManager: BaseCoreDataManager<CDImage>, @unchecked Sendable {
    @MainActor
    public func first(hashCode: String) -> Entity.Model? {
        firstOnMain(with: hashCode)?.codable
    }
}
