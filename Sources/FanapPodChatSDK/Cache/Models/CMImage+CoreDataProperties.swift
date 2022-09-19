//
//  CMImage.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData

extension CMImage {
    
    @NSManaged public var actualHeight: NSNumber?
    @NSManaged public var actualWidth:  NSNumber?
    @NSManaged public var hashCode:     String?
    @NSManaged public var height:       NSNumber?
    @NSManaged public var isThumbnail:  NSNumber?
    @NSManaged public var name:         String?
    @NSManaged public var size:         NSNumber?
    @NSManaged public var width:        NSNumber?
    
}
