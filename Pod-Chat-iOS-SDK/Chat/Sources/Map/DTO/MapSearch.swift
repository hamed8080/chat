//
//  MapSearch.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/23/21.
//

import Foundation

open class MapSearch {
    
    public var count:   Int
    public var items:   [MapItem]?
    
    public init(count: Int, items: [MapItem]) {
        self.count  = count
        self.items  = items
    }
}

