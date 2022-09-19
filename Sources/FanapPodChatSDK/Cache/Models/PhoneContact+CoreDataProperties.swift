//
//  PhoneContact.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData


extension PhoneContact {
    
    @NSManaged public var cellphoneNumber:  String?
    @NSManaged public var email:            String?
    @NSManaged public var firstName:        String?
    @NSManaged public var lastName:         String?
}
