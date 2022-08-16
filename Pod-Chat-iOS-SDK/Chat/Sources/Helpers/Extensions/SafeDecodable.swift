//
//  SafeDecodable.swift
//  FanapPodChatSDK
//
//  Created by hamed on 7/25/22.
//

import Foundation

public protocol SafeDecodable: Decodable & CaseIterable & RawRepresentable where RawValue: Decodable, AllCases: BidirectionalCollection { }


extension SafeDecodable {

    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
