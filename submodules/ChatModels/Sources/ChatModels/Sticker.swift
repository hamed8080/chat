//
// Sticker.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum Sticker: Int, CaseIterable, Identifiable, Codable, Sendable {
    public var id: Self { self }
    case hifive = 1
    case like = 2
    case happy = 3
    case cry = 4
    case thumbsdown = 5
    case redHeart = 6
    case angryFace = 7
    case verification = 8
    case heartEyes = 9
    case clappingHands = 10
    case faceScreaming = 11
    case flushingFace = 12
    case grimacingFace = 13
    case noExpressionFace = 14
    case rofl = 15
    case facepalmingGirl = 16
    case facepalmingBoy = 17
    case swearingFace = 18
    case blowingAKissFace = 19
    case seeNnoEvilMonkey = 20
    case tulip = 21
    case greenHeart = 22
    case purpleHeart = 23
    case bdCake = 24
    case hundredPoints = 25
    case alarm = 26
    case partyPopper = 27
    case personWalking = 28
    case smilingPoo = 29
    case cryingLoudlyFace = 30


    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case unknown

    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
