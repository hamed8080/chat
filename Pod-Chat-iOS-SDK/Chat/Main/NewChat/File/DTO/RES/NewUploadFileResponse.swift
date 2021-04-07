//
//  NewUploadFileResponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/30/21.
//

import Foundation
public class NewUploadFileResponse: Decodable {
    
    let fileMetaDataResponse:FileMetaDataResponse?
    
    private enum CodingKeys : String ,CodingKey{
        case fileMetaData       = "result"
    }

    public required init(from decoder: Decoder) throws {
        let container           = try  decoder.container(keyedBy: CodingKeys.self)
        fileMetaDataResponse    = try container.decodeIfPresent(FileMetaDataResponse.self, forKey: .fileMetaData)
    }
    
}

public class FileMetaDataResponse : Decodable{
    let name            : String?
    let hashCode        : String?
    let parentHash      : String?
    let created         : Int64?
    let size            : Int64?
    let type            : String?
    let actualHeight    : Int64?
    let actualWidth     : Int64?
}
