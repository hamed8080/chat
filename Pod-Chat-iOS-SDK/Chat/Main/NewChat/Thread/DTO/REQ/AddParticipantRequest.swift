//
//  AddParticipantRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
public class AddParticipantRequest: BaseRequest {
	
	public  let id       : String
	private let idType    : InviteeVoIdTypes
	public var threadId:Int
	
	public init(userName:String , threadId:Int,uniqueId: String? = nil, typeCode: String? = nil){
		idType = .TO_BE_USER_USERNAME
		self.id = userName
		self.threadId = threadId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	public init (contactId:Int,threadId:Int,uniqueId: String? = nil, typeCode: String? = nil){
		idType = .TO_BE_USER_CONTACT_ID
		self.id = "\(contactId)"
		self.threadId = threadId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	public init (coreUserId:Int,threadId:Int,uniqueId: String? = nil, typeCode: String? = nil){
		idType = .TO_BE_USER_ID
		self.id = "\(coreUserId)"
		self.threadId = threadId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
    
	private enum CodingKeys:String , CodingKey{
		case id = "id"
        case idType = "idType"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encode(id, forKey: .id)
        try? container.encode(idType, forKey: .idType)
	}
	
}
