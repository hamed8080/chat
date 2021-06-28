//
//  CacheFileManager.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 4/2/21.
//

import Foundation


enum FileManagerPaths: String {
    case Files = "/Chat/Files/"
    case Images = "/Chat/Images/"
}

class CacheFileManager{
    
    public static let sharedInstance = CacheFileManager()
    private let rootPath :String
    
    private init(){
        if let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            self.rootPath = rootPath
        }else{
            self.rootPath = ""
        }
    }
    
    func getFile(hashCode:String)->(file:FileModel,path:String)?{
        
        let predicate = NSPredicate(format: "hashCode == %@", hashCode , NSNumber(value: false))
        if let findedFile = CMFile.crud.fetchWith(predicate)?.first , let fileModel = findedFile.getCodable(){
            let filePath = rootPath + "/\(FileManagerPaths.Images.rawValue)/" + "\(findedFile.hashCode ?? "default")"
            return ( fileModel , filePath)
        }
        return nil
    }
    
    func getImage(hashCode:String)->(image:ImageModel,path:String)?{
        
        let predicate = NSPredicate(format: "hashCode == %@ AND isThumbnail == %@", hashCode , NSNumber(value: false))
        if let findedImage = CMImage.crud.fetchWith(predicate)?.first, let imageModel = findedImage.getCodable(){
            let imagePath = rootPath + "/\(FileManagerPaths.Images.rawValue)/" + "\(findedImage.hashCode ?? "default")"
            return (imageModel, imagePath)
        }
        return nil
    }
    
    func getThumbnail(hashCode:String)->(image:ImageModel,path:String)?{
        let predicate = NSPredicate(format: "hashCode == %@ AND isThumbnail == %@", hashCode , NSNumber(value: true))
        if let findedImage = CMImage.crud.fetchWith(predicate)?.first, let imageModel = findedImage.getCodable(){
            let imagePath = rootPath + "/\(FileManagerPaths.Images.rawValue)/" + "\(hashCode + "-Thumbnail")"
            return (imageModel, imagePath)
        }
        return nil
    }
    
    public func isImageAvailable(hashCode: String) -> Bool {
        return getImage(hashCode: hashCode) != nil
    }
    
    public func isFileAvailable(hashCode: String) -> Bool {
        return getFile(hashCode: hashCode) != nil
    }
    
    public func retrieveAllImagesSize() -> UInt64 {
        let path = rootPath + "/\(FileManagerPaths.Images.rawValue)"
        let documentsDirectoryURL = URL(fileURLWithPath: path)
        return (try? FileManager.default.allocatedSizeOfDirectory(at: documentsDirectoryURL)) ?? 0
    }
    
    public func retrieveAllFilesSize() -> UInt64 {
        let path = rootPath + "/\(FileManagerPaths.Files.rawValue)"
        let documentsDirectoryURL = URL(fileURLWithPath: path)
        return (try? FileManager.default.allocatedSizeOfDirectory(at: documentsDirectoryURL)) ?? 0
    }
    
    public func deleteAllFiles(){
        CMFile.crud.getAll().forEach { file in
            let filePath = rootPath + "/\(FileManagerPaths.Files.rawValue)/" + "\(file.hashCode ?? "default")"
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch {
                    fatalError("can not delete the file from app bundle!")
                }
            }
            CMFile.crud.delete(entity: file)
        }
        PSM.shared.save()
    }
    
    
    public func deleteAllImages(){
        CMImage.crud.getAll().forEach { image in
            let imagePath = rootPath + "/\(FileManagerPaths.Images.rawValue)/" + "\(image.hashCode ?? "default")"
            if FileManager.default.fileExists(atPath: imagePath) {
                do {
                    try FileManager.default.removeItem(atPath: imagePath)
                } catch {
                    fatalError("can not delete the file from app bundle!")
                }
            }
            CMImage.crud.delete(entity: image)
        }
        PSM.shared.save()
    }
    
    func deleteAllFilesWithCache(){
        deleteAllFiles()
        deleteAllImages()
    }
    
    func totoalUsedSpace()->UInt64{
        return retrieveAllFilesSize() + retrieveAllImagesSize()
    }
    
    func getDataOfFileWith(filePath:String)->Data?{
        let fileURL = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: filePath) , let data = try? Data(contentsOf: fileURL) {
            return data
        }else{
            return nil
        }
    }
    
    func saveFile(_ fileModel:FileModel , _ data:Data?){
        guard let data = data else{return}
        CMFile.crud.deleteWith(predicate: NSPredicate(format: "hashCode == %@", fileModel.hashCode))
        CMFile.insert(request: fileModel)
        createDirectoryIfNotExist(paths: .Files)
        PSM.shared.save()
        let url = URL(fileURLWithPath: rootPath + "/\(FileManagerPaths.Files.rawValue)").appendingPathComponent("\(fileModel.hashCode)")
        writeDataAt(url: url, data: data)
    }
    
    func saveImage(_ imageModel:ImageModel , _ isThumbnail:Bool , _ data:Data?){
        guard let data = data else{return}
        CMImage.crud.deleteWith(predicate: NSPredicate(format: "hashCode == %@", imageModel.hashCode))
        CMImage.insert(request: imageModel , isThumbnail:isThumbnail)
        createDirectoryIfNotExist(paths: .Images)
        PSM.shared.save()
        let url = URL(fileURLWithPath: rootPath + "/\(FileManagerPaths.Images.rawValue)").appendingPathComponent("\(imageModel.hashCode)")
        writeDataAt(url: url, data: data)
    }
    
    func createDirectoryIfNotExist(paths:FileManagerPaths){
        let directory = rootPath + paths.rawValue
        let url = URL(fileURLWithPath: directory)
        if !(FileManager.default.fileExists(atPath: directory, isDirectory: nil)) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                print("directory created at:\n \(url)")
            } catch {
                print("error on creating Directory \n\(error.localizedDescription)")
            }
        }
    }
    
    func writeDataAt(url:URL , data:Data){
        do {
            try data.write(to: url)
        } catch {
            print("error when try to write data on documentDirectory \n\(error.localizedDescription)")
        }
    }
    
}
