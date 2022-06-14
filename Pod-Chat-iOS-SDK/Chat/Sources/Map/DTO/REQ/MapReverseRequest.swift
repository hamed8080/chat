//
//  MapReverseRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/12/21.
//

import Foundation

public class MapReverseRequest :BaseRequest {
    
    public let lat:     Double
    public let lng:     Double
    
    public init(lat:Double,lng:Double ,uniqueId: String? = nil) {
        self.lat    = lat
        self.lng    = lng
        super.init(uniqueId: uniqueId)
    }
    
    private enum CodingKeys :String , CodingKey{
        case lat = "lat"
        case lng = "lng"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(lat, forKey: .lat)
        try? container.encode(lng, forKey: .lng)
    }
    
}
