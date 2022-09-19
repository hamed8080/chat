//
//  HTTPMethod.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/1/21.
//

import Foundation

internal enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}
