//
//  InviteeTypes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

public enum InviteeTypes : Int , Codable , CaseIterable {
    
    case TO_BE_USER_SSO_ID           = 1
    case TO_BE_USER_CONTACT_ID       = 2
    case TO_BE_USER_CELLPHONE_NUMBER = 3
    case TO_BE_USER_USERNAME         = 4
    case TO_BE_USER_ID               = 5
    case TO_BE_CORE_USER_ID          = 6
}


