//
//  OwnerTypeCode.swift
//  FanapPodChatSDK
//
//  Created by hamed on 2/18/24.
//

import Foundation

public struct OwnerTypeCode: Codable {
    public var typeCode: String
    public var ownerId: Int?

    public init(typeCode: String, ownerId: Int? = nil) {
        self.typeCode = typeCode
        self.ownerId = ownerId
    }
}
