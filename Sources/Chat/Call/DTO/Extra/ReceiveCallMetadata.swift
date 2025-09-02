//
// ReceiveCallMetadata.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

struct ReceiveCallMetadata: Decodable {
    let id: CallMetadataType
}

enum CallMetadataType: Int, Decodable {
    case poorconnection =  1
    case poorconnectionResolved =  2
    case customuserMetadata =  3
    case screenShareMetadata =  4
}
