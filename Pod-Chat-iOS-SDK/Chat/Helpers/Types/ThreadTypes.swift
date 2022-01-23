//
//  ThreadTypes.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum ThreadTypes : Int , Encodable ,CaseIterable {
    
    /// This type can be P2P only 2 user or can be a Private group.
    /// - If it's a Private Group only the admin can add participants to it.
    /// - Everyone can send messages to this type of thread.
    case NORMAL                 = 0
    
    /// Specifice type of group - Not impelemented yet.
    /// - Maybe in the future, this type has the ability to had an Owner as well as Admin.
    /// - No difference between the normal group and owner group at the moment.
    case OWNER_GROUP            = 1
    
    /// Everyone can join this or even can see message history of this thread without joining to the thread.
    /// - Everyone can send message to the thread.
    /// - Users can join with a link don't need an invitation from the admin.
    case PUBLIC_GROUP           = 2
    
    /// Private Channel only admin can send invitation to some one to join this thread.and Every one can send message to this thread.
    case CHANNEL_GROUP          = 4
    
    /// Private Channel - Only the admin can send an invitation to someone to join this thread.
    /// - Only admin can send message to this thread.
    case CHANNEL                = 8
    
    /// Not implemented yet.
    case NOTIFICATION_CHANNEL   = 16
    
    /// Not implemented yet.
    case PUBLIC_THREAD          = 32
    
    /// Everyone can join this channel and even users can get a history of this channel without joining it.
    /// - Only admin can send message to the thread.
    /// - Users can join with a link don't need an invitation from the admin.
    case PUBLIC_CHANNEL         = 64
    
    /// Only one user with no other participant.
    /// - Only the current user can send message to this thread.
    case SELF_THREAD            = 128
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func stringValue() -> String {
        switch self {
        case .NORMAL:               return "NORMAL"
        case .OWNER_GROUP:          return "OWNER_GROUP"
        case .PUBLIC_GROUP:         return "PUBLIC_GROUP"
        case .CHANNEL_GROUP:        return "CHANNEL_GROUP"
        case .CHANNEL:              return "CHANNEL"
        case .NOTIFICATION_CHANNEL: return "NOTIFICATION_CHANNEL"
        case .PUBLIC_THREAD:        return "PUBLIC_THREAD"
        case .PUBLIC_CHANNEL:       return "PUBLIC_CHANNEL"
        case .SELF_THREAD:          return "SELF_THREAD"
        }
    }
	
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func intValue() -> Int {
        switch self {
        case .NORMAL:               return 0
        case .OWNER_GROUP:          return 1
        case .PUBLIC_GROUP:         return 2
        case .CHANNEL_GROUP:        return 4
        case .CHANNEL:              return 8
        case .NOTIFICATION_CHANNEL: return 16
        case .PUBLIC_THREAD:        return 32
        case .PUBLIC_CHANNEL:       return 64
        case .SELF_THREAD:          return 128
        }
    }
    
}


