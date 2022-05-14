//
//  Pagination.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/14/21.
//

import Foundation
public struct Pagination : Decodable{
    
    public let hasNext    :Bool
    public let totalCount :Int
    public let count      :Int
    public let offset     :Int
    public let nextOffset :Int?
    
    public init(count:Int = 50 , offset:Int = 0 ,totalCount:Int? = 0){
        hasNext          = (totalCount ?? 0) >  (count + offset)
        self.count       = count
        self.offset      = offset
        self.totalCount  = totalCount ?? 0
        self.nextOffset  = offset + count > self.totalCount ? nil : offset + count
    }
    
}
