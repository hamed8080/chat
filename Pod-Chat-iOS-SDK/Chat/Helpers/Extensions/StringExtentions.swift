//
//  StringExtentions.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 1/30/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
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


extension String {
    
    func convertToJSON() -> JSON {
        if let dataFromStringMsg = self.data(using: .utf8, allowLossyConversion: false) {
            if let msg = try? JSON(data: dataFromStringMsg) {
                return msg
            } else {
                return []
            }
//            do {
//                let msg = try JSON(data: dataFromStringMsg)
//                return msg
//            } catch {
//                //                log.error("error to convert income message String to JSON", context: "formatStringToJSON")
//                return []
//            }
        } else {
            //            log.error("error to get message from server", context: "formatStringToJSON")
            return []
        }
    }

    public func removeBackSlashes()->String{
        return self.replacingOccurrences(of: "\\\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\"{", with: "\n{")
        .replacingOccurrences(of: "}\"", with: "}\n")
        .replacingOccurrences(of: "\"[", with: "\n[")
        .replacingOccurrences(of: "]\"", with: "]\n")
    }
}
