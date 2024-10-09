//
// LogEmitter.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation

public enum LogEmitter: Int, CaseIterable, Codable, Identifiable {
    public var id: Self { self }
    case internalLog = 0
    case sent = 1
    case received = 2
}
