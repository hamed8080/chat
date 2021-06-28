//
//  InviteeVoIdTypes.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum InviteeVoIdTypes : Int , Codable , CaseIterable {
    
    case TO_BE_USER_SSO_ID = 1
    case TO_BE_USER_CONTACT_ID = 2
    case TO_BE_USER_CELLPHONE_NUMBER = 3
    case TO_BE_USER_USERNAME = 4
    case TO_BE_USER_ID = 5
    case TO_BE_CORE_USER_ID = 6
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func stringValue() -> String {
        switch self {
        case .TO_BE_USER_SSO_ID:            return "TO_BE_USER_SSO_ID"
        case .TO_BE_USER_CONTACT_ID:        return "TO_BE_USER_CONTACT_ID"
        case .TO_BE_USER_CELLPHONE_NUMBER:  return "TO_BE_USER_CELLPHONE_NUMBER"
        case .TO_BE_USER_USERNAME:          return "TO_BE_USER_USERNAME"
        case .TO_BE_USER_ID:                return "TO_BE_USER_ID"
        case .TO_BE_CORE_USER_ID:           return "TO_BE_CORE_USER_ID"
        }
    }
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func intValue() -> Int {
        switch self {
        case .TO_BE_USER_SSO_ID:            return 1
        case .TO_BE_USER_CONTACT_ID:        return 2
        case .TO_BE_USER_CELLPHONE_NUMBER:  return 3
        case .TO_BE_USER_USERNAME:          return 4
        case .TO_BE_USER_ID:                return 5
        case .TO_BE_CORE_USER_ID:           return 6
        }
    }
    
}


