//
// ImageSize.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum ImageSize: String, Encodable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }
    case SMALL
    case MEDIUM
    case LARG
    case ACTUAL
    case CUSTOM
}
