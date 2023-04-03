//
// Bundle+.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/16/22

import Foundation

extension Bundle {
    static var moduleBundle: Bundle {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(identifier: "org.cocoapods.Chat") ?? Bundle.main
        #endif
    }
}
