//
//  CustomerInfo.swift
//  FanapPodChatSDK
//
//  Created by hamed on 8/20/22.
//

import Foundation

public struct CustomerInfo: Decodable {

    public let firstName: String?
    public let lastName: String?
    public let username: String?
    public let email: String?
    public let cellphoneNumber: String?
    public let cardGroupName: String?
    public let address: String?

    public init(firstName: String? = nil, lastName: String? = nil, username: String? = nil, email: String? = nil, cellphoneNumber: String? = nil, cardGroupName: String? = nil, address: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.cellphoneNumber = cellphoneNumber
        self.cardGroupName = cardGroupName
        self.address = address
    }

}
