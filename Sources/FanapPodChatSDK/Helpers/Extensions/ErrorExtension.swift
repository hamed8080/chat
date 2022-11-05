//
// ErrorExtension.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

extension Error {
    func printError(message: String? = nil) {
        Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: message ?? " localizedError:" + localizedDescription)
    }
}
