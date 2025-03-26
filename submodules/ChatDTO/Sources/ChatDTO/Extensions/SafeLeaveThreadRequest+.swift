//
// SafeLeaveThreadRequest+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public extension SafeLeaveThreadRequest {
    var generalRequest: GeneralSubjectIdRequest {
        GeneralSubjectIdRequest(subjectId: threadId, uniqueId: uniqueId)
    }

    func roleRequest(roles: [Roles]) -> RolesRequest {
        RolesRequest(userRoles: [.init(userId: participantId, roles: roles)], threadId: threadId, uniqueId: uniqueId)
    }
}
