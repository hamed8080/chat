//
//  MapSearchRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/12/21.
//

import Foundation

public class MapSearchRequest : BaseRequest {
    
    public let lat:     Double
    public let lng:     Double
    public let term:    String
    
    public init(lat:    Double,
                lng:    Double,
                term:   String,
                typeCode: String? = nil,
                uniqueId: String? = nil) {
        
        self.lat    = lat
        self.lng    = lng
        self.term   = term
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    private enum CodingKeys:String , CodingKey{
        case lat = "lat"
        case lng = "lng"
        case term = "term"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(lat, forKey: .lat)
        try? container.encode(lng, forKey: .lng)
        try? container.encode(term, forKey: .term)
    }
    
}
