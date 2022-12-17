//
// Bundle+.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/16/22

import Foundation

extension Bundle {
    static var moduleBundle: Bundle {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(identifier: "org.cocoapods.FanapPodChatSDK") ?? Bundle.main
        #endif
    }
}
