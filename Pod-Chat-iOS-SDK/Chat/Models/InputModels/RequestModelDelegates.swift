//
//  RequestModelDelegates.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/2/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
public protocol RequestModelDelegates {
    func convertContentToJSON() -> JSON
    func convertContentToJSONArray() -> [JSON]
}


