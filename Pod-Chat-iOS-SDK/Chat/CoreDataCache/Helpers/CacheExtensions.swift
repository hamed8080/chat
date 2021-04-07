//
//  CacheExtensions.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

extension NSObject {
    
    /*
     use this two methods to convert transformable data to JSON and viseversa
     */
    
    static func convertJSONtoTransformable(dataToStore: JSON, completion: (NSData?) -> Void) {
        if let data = try? JSONSerialization.data(withJSONObject: dataToStore, options: []) {
            completion(data as NSData)
        } else {
            print("NSJSONSerialization Error")
            completion(nil)
        }
//        do {
//            let data = try JSONSerialization.data(withJSONObject: dataToStore, options: [])
//            completion(data as NSData)
//        } catch let error as NSError {
//            print("NSJSONSerialization Error: \(error)")
//            completion(nil)
//        }
    }
    
    func retrieveJSONfromTransformableData(completion: (JSON) -> Void) {
        if let data = self as? NSData {
            if let nsJSON = try? JSONSerialization.jsonObject(with: data as Data, options: []) {
                completion(JSON(nsJSON))
            } else {
                print("NSJSONSerialization Error")
                completion(JSON.null)
            }
//            do {
//                let nsJSON = try JSONSerialization.jsonObject(with: data as Data, options: [])
//                completion(JSON(nsJSON))
//            } catch let error as NSError {
//                print("NSJSONSerialization Error: \(error)")
//                completion(JSON.null)
//            }
        }
    }
    
}


