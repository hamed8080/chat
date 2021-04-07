//
//  UpdateContactRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/1/21.
//

import Foundation

public struct UpdateContactRequest :Encodable {
	
	public let cellphoneNumber: String
	public let email:           String
	public let firstName:       String
	public let id:              Int
	public let lastName:        String
	public let username:        String
	
	public var typeCode:        String?
	public var uniqueId:        String?
	
	public init(cellphoneNumber:    String,
				email:              String,
				firstName:          String,
				id:                 Int,
				lastName:           String,
				username:           String,
				uniqueId:		    String? = nil,
				typeCode:		    String? = nil
				) {
		
		self.cellphoneNumber    = cellphoneNumber
		self.email              = email
		self.firstName          = firstName
		self.id                 = id
		self.lastName           = lastName
		self.username           = username
		self.uniqueId 		= uniqueId ?? UUID().uuidString //need to send to server
		self.typeCode 		= typeCode
	}

}
