//
// File+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public extension File {

    init(hashCode: String, headers: [String: Any]){
        var name: String?
        if let fileName = (headers["Content-Disposition"] as? String)?.replacingOccurrences(of: "\"", with: "").split(separator: "=").last {
            name = String(fileName)
        }
        var type: String?
        if let mimetype = (headers["Content-Type"] as? String)?.split(separator: "/").last {
            type = String(mimetype)
        }
        let size = Int((headers["Content-Length"] as? String) ?? "0")
        let fileNameWithExtension = "\(name ?? "default").\(type ?? "none")"
        self.init(hashCode: hashCode, name: fileNameWithExtension, size: size, type: type)
    }
}
