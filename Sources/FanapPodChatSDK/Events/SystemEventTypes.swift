//
//  SystemEventTypes.swift
//  FanapPodChatSDK
//
//  Created by hamed on 5/23/22.
//

import Foundation

public enum SystemEventTypes{

    case SYSTEM_MESSAGE(message: SystemEventMessageModel, time:Int, id:Int?)
    case SERVER_TIME(Int)
}
