//
//  CMMutualGroup.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//


import Foundation
import CoreData

public class CMMutualGroup : NSManagedObject {

    @NSManaged public var mutualId:String?
    @NSManaged public var idType:NSNumber?
    @NSManaged public var conversation : CMConversation?
}
