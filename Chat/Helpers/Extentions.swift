//
//  Extentions.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import Async


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
}



struct formatDataFromStringToJSON {
    let stringCont: String
    
    func convertStringContentToJSON() -> JSON {
        if let dataFromStringMsg = stringCont.data(using: .utf8, allowLossyConversion: false) {
            do {
                let msg = try JSON(data: dataFromStringMsg)
                return msg
            } catch {
                log.error("error to convert income message String to JSON", context: "formatStringToJSON")
                return []
            }
        } else {
            log.error("error to get message from server", context: "formatStringToJSON")
            return []
        }
    }
}


