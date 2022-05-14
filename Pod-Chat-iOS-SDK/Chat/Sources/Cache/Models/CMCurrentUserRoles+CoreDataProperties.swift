//
//  CMCurrentUserRoles.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData

extension CMCurrentUserRoles {
    
    @NSManaged public var threadId: NSNumber?
    @NSManaged public var roles:    RolesArray?
}
