//
//  CMLinkedUser.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData

extension CMLinkedUser {
    
    @NSManaged public var coreUserId:   NSNumber?
    @NSManaged public var image:        String?
    @NSManaged public var name:         String?
    @NSManaged public var nickname:     String?
    @NSManaged public var username:     String?
    @NSManaged public var dummyContact: CMContact?

}
