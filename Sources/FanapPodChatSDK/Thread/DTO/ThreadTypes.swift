//
//  ThreadTypes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

/// Type of thread.
public enum ThreadTypes : Int, Codable, SafeDecodable {
    
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


    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case UNKNOWN
}


