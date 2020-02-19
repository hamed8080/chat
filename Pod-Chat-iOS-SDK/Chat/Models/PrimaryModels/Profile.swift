//
//  Profile.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class Profile {
    
    public var bio:         String?
    public var metadata:    String?
    
    public init(messageContent: JSON) {
        self.bio        = messageContent["bio"].string
        self.metadata   = messageContent["metadata"].string
    }
    
    public init(bio:        String?,
                metadata:   String?) {
        self.bio        = bio
        self.metadata   = metadata
    }
    
    public init(theProfile: Profile) {
        self.bio        = theProfile.bio
        self.metadata   = theProfile.metadata
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["bio":      bio ?? NSNull(),
                            "metadata": metadata ?? NSNull()]
        return result
    }
    
}
