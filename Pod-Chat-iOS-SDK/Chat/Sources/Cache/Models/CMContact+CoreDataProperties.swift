//
//  CMContact.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData

extension CMContact {
    
    @NSManaged public var blocked:          NSNumber?
    @NSManaged public var cellphoneNumber:  String?
    @NSManaged public var email:            String?
    @NSManaged public var firstName:        String?
    @NSManaged public var hasUser:          NSNumber?
    @NSManaged public var id:               NSNumber?
    @NSManaged public var image:            String?
    @NSManaged public var lastName:         String?
    @NSManaged public var notSeenDuration:  NSNumber?
    @NSManaged public var time:             NSNumber?
    @NSManaged public var uniqueId:         String?
    @NSManaged public var userId:           NSNumber?
    @NSManaged public var linkedUser:       CMLinkedUser?

}
