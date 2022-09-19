//
//  CMFile.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData

extension CMFile {
    
    @NSManaged public var hashCode: String?
    @NSManaged public var name:     String?
    @NSManaged public var size:     NSNumber?
    @NSManaged public var type:     String?
    
}
