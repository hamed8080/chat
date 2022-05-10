//
//  QueueOfFileMessages.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import CoreData


extension QueueOfFileMessages {

    @NSManaged public var textMessage:  String?
    @NSManaged public var fileExtension: String?
    @NSManaged public var fileName:     String?
    @NSManaged public var isPublic:     NSNumber?
    @NSManaged public var messageType:  NSNumber?
    @NSManaged public var metadata:     String?
    @NSManaged public var mimeType:     String?
    @NSManaged public var originalName: String?
    @NSManaged public var repliedTo:    NSNumber?
    @NSManaged public var threadId:     NSNumber?
    @NSManaged public var userGroupHash: String?
    @NSManaged public var xC:           NSNumber?
    @NSManaged public var yC:           NSNumber?
    @NSManaged public var hC:           NSNumber?
    @NSManaged public var wC:           NSNumber?
    
    @NSManaged public var typeCode:     String?
    @NSManaged public var uniqueId:     String?
    
    @NSManaged public var fileToSend:   NSData?
    @NSManaged public var imageToSend:  NSData?

}
