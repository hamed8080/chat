//
//  CMPinMessage.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData

extension CMPinMessage {

    @NSManaged public var messageId:    NSNumber?
    @NSManaged public var text:         String?
    @NSManaged public var notifyAll:    NSNumber?
    @NSManaged public var message:      CMMessage?

}
