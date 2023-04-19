//
//  File.swift
//  
//
//  Created by hamed on 4/16/23.
//

import ChatModels
import ChatDTO
import Foundation

public extension Contact {
    var request: AddContactRequest {
        let req = AddContactRequest(
            email: email,
            firstName: firstName,
            lastName: lastName,
            username: user?.username,
            uniqueId: UUID().uuidString
        )
        req.cellphoneNumber = cellphoneNumber
        return req
    }
}
