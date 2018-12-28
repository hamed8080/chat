//
//  MuteAndUnmuteThreadRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class MuteAndUnmuteThreadRequestModel {
    
    public let subjectId:   Int
    public let typeCode:    String?
    
    public init(subjectId: Int, typeCode: String?) {
        self.subjectId  = subjectId
        self.typeCode   = typeCode
    }
    
}


