//
//  EncodableExtensions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/3/21.
//

import Foundation
extension Encodable{
	
	func convertCodableToString()->String? {
		if let data = try? JSONEncoder().encode(self){
			return String(data: data, encoding: .utf8)
		}else{
			return nil
		}
	}
	
	func asDictionary() throws -> [String: Any] {
		let data = try JSONEncoder().encode(self)
		guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
			throw NSError()
		}
		return dictionary
	}
	
	
	//only for print data for log and debugging in xcode
	func printAsyncJson(receive:Bool = false){
        if FanapPodChatSDK.Chat.sharedInstance.createChatModel?.isDebuggingLogEnabled == false {return}
        do{
            
            let data = try JSONEncoder().encode(self)
            let string = String(data: data, encoding: .utf8)?
                .replacingOccurrences(of: "\\\"", with: "\"")
                .replacingOccurrences(of: "\\\"", with: "\"")
                .replacingOccurrences(of: "\\\"", with: "\"")
                .replacingOccurrences(of: "\\\\\"", with: "\"")
                .replacingOccurrences(of: "\\\"", with: "\"")
                .replacingOccurrences(of: "\\\"", with: "\"")
                .replacingOccurrences(of: "\"{", with: "{")
                .replacingOccurrences(of: "}\"", with: "}")
                .replacingOccurrences(of: "\"[", with: "[")
                .replacingOccurrences(of: "]\"", with: "]") ?? ""
            let stringData = string.data(using: .utf8) ?? Data()
            let jsonObject = try JSONSerialization.jsonObject(with: stringData, options: .mutableContainers)
            let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            let prettyString = String(data: prettyJsonData, encoding: .utf8) ?? ""
            print("json \(receive ? "recived" : "sent") is:\n" + (prettyString ) + "\n" )
        }catch{
            guard let data = try? JSONEncoder().encode(self) else{return}
            let string = String(data: data, encoding: .utf8)
            print("\(string ?? "")")
        }
        
	}
}
