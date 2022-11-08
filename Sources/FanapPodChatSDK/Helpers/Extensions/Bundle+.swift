//
//  Bundle+.swift
//  FanapPodChatSDK
//
//  Created by hamed on 11/8/22.
//

import Foundation

extension Bundle {
    static var moduleBundle: Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle(identifier: "org.cocoapods.FanapPodChatSDK") ?? Bundle.main
#endif
    }
}
