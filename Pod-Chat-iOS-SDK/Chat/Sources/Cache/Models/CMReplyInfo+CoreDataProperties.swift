//
//  CMReplyInfo.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData


extension CMReplyInfo {

    @NSManaged public var messageId:        NSNumber?
    @NSManaged public var deletedd:         NSNumber?
    @NSManaged public var message:          String?
    @NSManaged public var messageType:      NSNumber?
    @NSManaged public var metadata:         String?
    @NSManaged public var repliedToMessageId: NSNumber?
    @NSManaged public var systemMetadata:   String?
    @NSManaged public var time:             NSNumber?
    @NSManaged public var dummyMessage:     CMMessage?
    @NSManaged public var participant:      CMParticipant?

}
