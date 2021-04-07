//
//  ResponseModelDelegates.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
protocol ResponseModelDelegates {
    func returnDataAsJSON() -> JSON
}
