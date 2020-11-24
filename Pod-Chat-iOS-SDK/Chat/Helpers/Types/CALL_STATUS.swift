//
//  CALL_STATUS.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation


enum CALL_STATUS {
    
    case REQUESTED
    case CANCELED
    case MISS
    case DECLINED
    case ACCEPTED
    case STARTED
    case ENDED
    case LEAVE
    
    func returnIntValue() -> Int {
        switch self {
        case .REQUESTED:    return 1
        case .CANCELED:     return 2
        case .MISS:         return 3
        case .DECLINED:     return 4
        case .ACCEPTED:     return 5
        case .STARTED:      return 6
        case .ENDED:        return 7
        case .LEAVE:        return 8
        }
    }
    
}
