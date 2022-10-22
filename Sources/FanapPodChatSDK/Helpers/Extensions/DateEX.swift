//
// DateEX.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

extension Date {
    func getDurationTimerString() -> String {
        let interval = Date().timeIntervalSince1970 - timeIntervalSince1970
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return formatter.string(from: interval) ?? ""
    }

    func getTime(localIdentifire: String = "en_US") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: localIdentifire)
        return formatter.string(from: self)
    }

    func getDate(localIdentifire: String = "en_US") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: localIdentifire)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
