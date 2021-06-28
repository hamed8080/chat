//
//  Extentions.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import FanapPodAsyncSDK


extension JSON {
    mutating func appendIfArray(json: JSON) {
        if var arr = self.array {
            arr.append(json)
            self = JSON(arr)
        }
    }
    
    mutating func appendIfDictionary(key: String, json: JSON) {
        if var dict = self.dictionary {
            dict[key] = json
            self = JSON(dict)
        }
    }
    
    mutating func merge(other: JSON) {
        for (key, subJson) in other {
            self[key] = subJson
        }
    }

    func merged(other: JSON) -> JSON {
        var merged = self
        merged.merge(other: other)
        return merged
    }
    
}


