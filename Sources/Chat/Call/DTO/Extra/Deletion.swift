//
// Deletion.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

struct Deletion: Codable {
    let mline: Int
    let clientId: Int
    let topic: String
    let mediaType: MediaType
    let mids: [String]
}
