//
// Contact+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatModels
import ChatDTO
import Foundation

public extension Contact {
    var request: AddContactRequest {
        var req = AddContactRequest(
            email: email,
            firstName: firstName,
            lastName: lastName,
            username: user?.username
        )
        req.cellphoneNumber = cellphoneNumber
        return req
    }
}
