//
//  EncodableExtensions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/3/21.
//

import Foundation
extension Encodable{
	
	public func convertCodableToString()->String? {
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
        if Chat.sharedInstance.config?.isDebuggingLogEnabled == false {return}
        do{
            
            let data = try JSONEncoder().encode(self)
            let string = String(data: data, encoding: .utf8)?.removeBackSlashes() ?? ""
            let stringData = string.data(using: .utf8) ?? Data()
            let jsonObject = try JSONSerialization.jsonObject(with: stringData, options: .mutableContainers)
            let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            let prettyString = String(data: prettyJsonData, encoding: .utf8) ?? ""
            print("json \(receive ? "recived" : "sent") is:\n" + (prettyString ) + "\n" )
            notifyObserverIfEnabled(json: prettyString,receive: receive)
        }catch{
            guard let data = try? JSONEncoder().encode(self) else{return}
            let string = String(data: data, encoding: .utf8)
            print(("json \(receive ? "recived" : "sent") is:\n" + (string ?? "") + "\n"))
            notifyObserverIfEnabled(json: string ?? "",receive: receive)
        }
        
	}
    
    func notifyObserverIfEnabled(json:String , receive:Bool){
        if Chat.sharedInstance.config?.enableNotificationLogObserver == true{
            NotificationCenter.default.post(name: Notification.Name("log"),object: LogResult(json: json, receive: receive))
        }
    }
    
    func convertToGETMethodQueeyString(url:String)->String?{
        var queryStringUrl = url
        if let parameters = try? self.asDictionary() , parameters.count > 0{
            var urlComp = URLComponents(string: url)!
            urlComp.queryItems = []
            parameters.forEach { key, value in
                urlComp.queryItems?.append(URLQueryItem(name: key, value: "\(value)"))
            }
            queryStringUrl = urlComp.url?.absoluteString ?? url
            return queryStringUrl
        }
        return nil
    }
    
    func getParameterData()->Data?{
        var parameterString = ""
        if let parameters = try? self.asDictionary() , parameters.count > 0{
            parameters.forEach { key, value in
                let isFirst = parameters.first?.key == key
                parameterString.append("\(isFirst ? "" : "&")\(key)=\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
            }
            return parameterString.data(using: .utf8)
        }
        return nil
    }
}
