//
// CallClientErrorType.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public enum CallClientErrorType: Int, Codable, Sendable {
    case microphoneNotAvailable = 3000
    case cameraNotAvailable = 3001
}
