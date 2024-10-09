//
// CallState.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

enum CallState: String {
    case requested
    case created
    case canceled
    case started
    case ended
    case initializeWebrtc
}
