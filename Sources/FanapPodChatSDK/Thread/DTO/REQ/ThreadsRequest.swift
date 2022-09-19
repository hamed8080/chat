//
//  ThreadsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

public class ThreadsRequest : BaseRequest {
	
    public let count                : Int
    public let offset               : Int
    public var name                 : String?  = nil
    public let new                  : Bool?
    public let threadIds            : [Int]?
    public let creatorCoreUserId    : Int?
    public let partnerCoreUserId    : Int?
	public let partnerCoreContactId : Int?
    public var metadataCriteria     : String?  = nil
	
	
	
    public init(count                : Int       = 50 ,
                offset               : Int       = 0,
                name                 : String?   = nil,
                new                  : Bool?     = nil,
                threadIds            : [Int]?    = nil,
                creatorCoreUserId    : Int?      = nil,
                partnerCoreUserId    : Int?      = nil,
                partnerCoreContactId : Int?      = nil,
                metadataCriteria     : String?   = nil,
                uniqueId             : String?   = nil
    )
	{
		self.count                = count
		self.offset               = offset
        self.name                 = name
        self.metadataCriteria     = metadataCriteria
		self.new                  = new
		self.threadIds            = threadIds
		self.creatorCoreUserId    = creatorCoreUserId
		self.partnerCoreUserId    = partnerCoreUserId
		self.partnerCoreContactId = partnerCoreContactId
        super.init(uniqueId: uniqueId)
	}
	
	private enum CodingKeys :String ,CodingKey{
		case count                = "count"
		case offset               = "offset"
		case name                 = "name"
		case new                  = "new"
		case threadIds            = "threadIds"
		case creatorCoreUserId    = "creatorCoreUserId"
		case partnerCoreUserId    = "partnerCoreUserId"
		case partnerCoreContactId = "partnerCoreContactId"
		case metadataCriteria     = "metadataCriteria"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encode(count, forKey: .count)
		try? container.encode(offset, forKey: .offset)
		try? container.encodeIfPresent(name, forKey: .name)
		try? container.encodeIfPresent(new, forKey: .new)
		try? container.encodeIfPresent(threadIds, forKey: .threadIds)
		try? container.encodeIfPresent(creatorCoreUserId, forKey: .creatorCoreUserId)
		try? container.encodeIfPresent(partnerCoreUserId, forKey: .partnerCoreUserId)
		try? container.encodeIfPresent(partnerCoreContactId, forKey: .partnerCoreContactId)
		try? container.encodeIfPresent(metadataCriteria, forKey: .metadataCriteria)
	}
}
