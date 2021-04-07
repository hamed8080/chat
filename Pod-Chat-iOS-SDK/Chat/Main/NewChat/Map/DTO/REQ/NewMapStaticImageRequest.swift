//
//  NewMapStaticImageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/1/21.
//

import Foundation

open class NewMapStaticImageRequest : Encodable {
	
	public var key    : String?
	public var center : String
	public var height : Int      = 500
	public var type   : String = "standard-night"
	public var width  : Int     = 800
	public var zoom   : Int    = 15
	
    public init(center:Cordinate,
				key:String? = nil,
				height:Int = 500,
				width:Int = 800,
				zoom:Int = 15,
				type:String = "standard-night"
	) {
        self.center = "\(center.lat),\(center.lng)"
		self.type = type
		self.height = height
		self.width = width
		self.zoom = zoom
		self.key = key
	}
	
}


