//
//  ErrorExtension.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 8/17/21.
//

import Foundation

extension Error{
    
    func printError(message:String? = nil){
        print(message ?? " localizedError:" +  localizedDescription)
    }
}
