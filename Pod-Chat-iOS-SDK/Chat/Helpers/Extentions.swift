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



extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}


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

/*
 * this is deprecated because of using extention on String
 struct FormatContentFromString {
 let stringCont: String
 
 func convertToJSON() -> JSON {
 if let dataFromStringMsg = stringCont.data(using: .utf8, allowLossyConversion: false) {
 do {
 let msg = try JSON(data: dataFromStringMsg)
 return msg
 } catch {
 //                log.error("error to convert income message String to JSON", context: "formatStringToJSON")
 return []
 }
 } else {
 //            log.error("error to get message from server", context: "formatStringToJSON")
 return []
 }
 }
 }
 */



extension String {
    
    func convertToJSON() -> JSON {
        if let dataFromStringMsg = self.data(using: .utf8, allowLossyConversion: false) {
            do {
                let msg = try JSON(data: dataFromStringMsg)
                return msg
            } catch {
                //                log.error("error to convert income message String to JSON", context: "formatStringToJSON")
                return []
            }
        } else {
            //            log.error("error to get message from server", context: "formatStringToJSON")
            return []
        }
    }
}


