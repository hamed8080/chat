//
// Bundle+.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
extension Bundle {
    static var moduleBundle: Bundle {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(identifier: "org.cocoapods.Logger") ?? Bundle.main
        #endif
    }
}
