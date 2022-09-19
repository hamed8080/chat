//
//  CMForwardInfo.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData

extension CMForwardInfo {
    
    @NSManaged public var messageId:    NSNumber?
    @NSManaged public var conversation: CMConversation?
    @NSManaged public var dummyMessage: CMMessage?
    @NSManaged public var participant:  CMParticipant?

}
