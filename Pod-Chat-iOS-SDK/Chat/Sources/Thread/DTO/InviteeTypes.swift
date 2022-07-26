//
//  InviteeTypes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

public enum InviteeTypes : Int , Codable , SafeDecodable {
    
    case SSO_ID                = 1
    case CONTACT_ID            = 2
    case CELLPHONE_NUMBER      = 3
    case USERNAME              = 4
    case USER_ID               = 5
    case CORE_USER_ID          = 6

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case UNKNOWN
}


