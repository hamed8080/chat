//
//  SystemEventMessageModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/21/21.
//

import Foundation
struct SystemEventMessageModel : Codable {
    
    let coreUserId :Int64
    let smt        :SystemEventTypes
    let userId     :Int
    let ssoId      :String
    let user       :String
}
