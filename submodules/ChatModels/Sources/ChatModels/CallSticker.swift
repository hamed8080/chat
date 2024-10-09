//
// CallSticker.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public enum CallSticker: String, Codable, CaseIterable {
    case raiseHand = "raise_hand"
    case like
    case dislike
    case clap
    case heart
    case happy
    case angry
    case cry
    case power
    case bored
}
