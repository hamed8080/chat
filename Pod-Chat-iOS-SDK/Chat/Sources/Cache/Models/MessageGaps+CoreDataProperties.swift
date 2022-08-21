//
//  MessageGaps.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//


import Foundation
import CoreData


extension MessageGaps {
    @NSManaged public var messageId:    NSNumber?
    @NSManaged public var threadId:     NSNumber?
    @NSManaged public var previousId:   NSNumber?
}
