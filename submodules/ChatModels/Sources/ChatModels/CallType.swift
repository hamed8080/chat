//
// CallType.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public enum CallType: Int, Codable, Sendable {
    case voiceCall = 0
    case videoCall = 1
}
