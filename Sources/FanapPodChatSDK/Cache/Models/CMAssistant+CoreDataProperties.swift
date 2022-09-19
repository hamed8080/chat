//
//  CMAssistant.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData

extension CMAssistant {
    @NSManaged public var inviteeId   : NSNumber? //inviteeId == participant.Id
    @NSManaged public var contactType : String?
    @NSManaged public var assistant   : NSData?
    @NSManaged public var participant : CMParticipant?
    @NSManaged public var roles       : [String]?
    @NSManaged public var block       : NSNumber
}
