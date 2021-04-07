//
//  RequestManager.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/1/21.
//

import Foundation
class RequestManager{
    
    class func request<D:Decodable>(ofType:D.Type,
                              bodyData:Data?,
                              url:      String,
                              method:       NewHTTPMethod,
                              headers:      [String:String]?,
                              completion:  @escaping CompletionTypeWithoutUniqueId<D>
    ){
        
        guard let url = URL(string: url) else { print("could not open url, it was nil"); return }
        
        let session                    = URLSession(configuration : .default)
        var urlRequest                 = URLRequest(url : url)
        urlRequest.httpMethod          = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody            = bodyData
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else{return}
            
            DispatchQueue.main.async {
                if let data = data , let chatError = try? JSONDecoder().decode(ChatError.self, from: data) , chatError.hasError == true{
                    completion(nil , chatError)
                }else if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300 , let data = data , let codable = try? JSONDecoder().decode(D.self, from: data){
                    completion(codable,nil)
                }else if let error = error{
                    let error = ChatError(message: "\(ChatErrors.err6200.stringValue()) \(error)", errorCode: httpResponse.statusCode, hasError: true)
                    completion(nil,error)
                }else {
                    let error = ChatError(message: "\(ChatErrors.err6200.stringValue())", errorCode: httpResponse.statusCode, hasError: true)
                    completion(nil,error)
                }
            }
        }
        task.resume()
    }
}
