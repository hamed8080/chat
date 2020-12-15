//
//  ConsoleLogLevel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/25/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyBeaver
import FanapPodAsyncSDK


public enum ConsoleLogLevel {
    case ERROR
    case WARNING
    case DEBUG
    case INFO
    case VERBOSE
    
    func logLevel() -> LogLevel {
        switch self {
        case .ERROR:    return LogLevel.error
        case .WARNING:  return LogLevel.warning
        case .DEBUG:    return LogLevel.debug
        case .INFO:     return LogLevel.info
        case .VERBOSE:  return LogLevel.verbose
        }
    }
}
