//
//  QueueOfUploadFiles+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension QueueOfUploadFiles{
    
    public static let crud = CoreDataCrud<QueueOfUploadFiles>(entityName: "QueueOfUploadFiles")
    
    public func getCodable() -> NewUploadFileRequest?{
        
        guard let fileData = dataToSend as Data? else{return nil}
        let uploadRequest = NewUploadFileRequest(data: fileData,
                                                 fileExtension: fileExtension,
                                                 fileName: fileName,
                                                 mimeType: mimeType,
                                                 originalName: originalName,
                                                 userGroupHash: userGroupHash,
                                                 typeCode: typeCode,
                                                 uniqueId: uniqueId)
        return uploadRequest
    }
    
    public class func convertFileToCM(request:NewUploadFileRequest ,entity:QueueOfUploadFiles? = nil) -> QueueOfUploadFiles{
        
        let model            = entity ?? QueueOfUploadFiles()
        
        model.dataToSend    = request.data as NSData
        model.fileExtension = request.fileExtension
        model.fileName      = request.fileName
        model.isPublic      = request.isPublic as NSNumber?
        model.mimeType      = request.mimeType
        model.originalName  = request.originalName
        model.userGroupHash = request.userGroupHash
        model.typeCode      = request.typeCode
        model.fileSize      = request.fileSize as NSNumber?
        model.uniqueId      = request.uniqueId
        
        return model
    }
    
    
    public class func insert(request:NewUploadFileRequest , resultEntity:((QueueOfUploadFiles)->())? = nil){
        
        if let entity = QueueOfUploadFiles.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId){
            resultEntity?(entity)
            return
        }
        
        QueueOfUploadFiles.crud.insert { cmEntity in
            let cmEntity = convertFileToCM(request: request , entity: cmEntity)
            resultEntity?(cmEntity)
        }
    }
    
}
