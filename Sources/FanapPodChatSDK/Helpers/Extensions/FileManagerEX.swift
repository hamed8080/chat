//
//  FileManagerEX.swift
//  FanapPodChatSDK
//
//  Created by hamed on 6/21/22.
//

import Foundation

extension FileManager{
    
    func appendToEndOfFile(data:Data, fileurl:URL){
        if FileManager.default.fileExists(atPath: fileurl.path){
            do {
                let fileHandle = try FileHandle(forWritingTo: fileurl)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }catch{
                print("Can't open file to append\(error.localizedDescription)")
            }
        }
    }
}
