//
// ReactionCountAction.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum ReactionCountAction: Sendable {
    case increase
    case decrease
    case set(Int)
}
