//
//  CustomerInfoRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

public class CustomerInfoRequest: BaseRequest {

    public let coreUserIds: [Int]

    public init(coreUserId: Int, uniqueId: String? = nil) {
        self.coreUserIds = [coreUserId]
        super.init(uniqueId: uniqueId)
    }
}
