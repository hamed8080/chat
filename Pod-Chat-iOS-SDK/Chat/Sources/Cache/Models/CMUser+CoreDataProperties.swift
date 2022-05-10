//
//  CMUser.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData


extension CMUser {
    
    @NSManaged public var cellphoneNumber:  String?
    @NSManaged public var contactSynced:    NSNumber?
    @NSManaged public var coreUserId:       NSNumber?
    @NSManaged public var email:            String?
    @NSManaged public var id:               NSNumber?
    @NSManaged public var image:            String?
    @NSManaged public var lastSeen:         NSNumber?
    @NSManaged public var name:             String?
    @NSManaged public var receiveEnable:    NSNumber?
    @NSManaged public var sendEnable:       NSNumber?
    @NSManaged public var username:         String?
    
    @NSManaged public var bio:              String?
    @NSManaged public var metadata:         String?
    
}
