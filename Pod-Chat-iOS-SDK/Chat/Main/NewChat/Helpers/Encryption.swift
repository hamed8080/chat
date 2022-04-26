//
//  Encryption.swift
//  FanapPodChatSDK
//
//  Created by hamed on 4/20/22.
//

import Foundation

class Encryption{
    
    ///Step 1:
    func startDecryption(_ message:Message){
        define(message)
    }
    
    ///Step 2:
    private func define(_ message:Message){
        guard let config = Chat.sharedInstance.config else{return}
        let url = "\(config.encryptionAddress)\(SERVICES_PATH.DEFINE.rawValue)"
        let headers: [String:String] = ["Authorization": "Bearer \(config.token)"]
        RequestManager.request(ofType: GetDefineSecretKeyResponse.self, bodyData: nil, url: url, method: .post, headers: headers) { [weak self] defineResponse, error in
            if let self = self, let defineResponse = defineResponse{
                self.getPrivateKey(defineResponse, message)
            }
        }
    }
    
    ///Step 3:
    private func getPrivateKey(_ defineMessage:GetDefineSecretKeyResponse,_ message:Message){
        guard let config = Chat.sharedInstance.config else{return}
        let url = "\(config.encryptionAddress)\(SERVICES_PATH.GENERATE_PRIVATE_KEY.rawValue)"
        let headers: [String:String] = ["Authorization": "Bearer \(config.token)", "X-Encrypt-KeyId" : ""]
        RequestManager.request(ofType: GetPrivateKeyResponse.self, bodyData: nil, url: url, method: .get, headers: headers) {  [weak self]  privateKeyResponse, error in
            if let self = self, let privateKeyResponse = privateKeyResponse{
                self.decrypt(message: message.message ?? "", privateKey: "")
            }
        }
    }
    
    ///Step 4:
    private func decrypt(message:String, privateKey:String)->String?{
        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: 2048,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ] as CFDictionary
        
        var error: Unmanaged<CFError>?
        guard let messageData = message.data(using: .utf8) as? NSData,
        let keyBytes = Data(base64Encoded: privateKey) as CFData?,
        let privateKey = SecKeyCreateWithData(keyBytes,attributes, &error),
        let decodedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionPKCS1, messageData, &error) as? Data else{return nil}
        let decodedString = String(data: decodedData, encoding: .utf8)
        return decodedString
    }
}

class GetDefineSecretKeyRequest:BaseRequest{
   
    let secretKey    :String
    let algorithm    :String

    
    internal init(secretKey: String, algorithm: String, typeCode: String? = nil, uniqueId: String? = nil) {
        self.secretKey     = secretKey
        self.algorithm     = algorithm
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    private enum CodingKeys:String ,CodingKey{
        case secretKey
        case algorithm
        case secretKeyId
    }
    
    override func encode(to encoder: Encoder) throws {
        
    }
}

class GetPrivateKeyRequest:BaseRequest{
   
    let keyId        :String
    let keyFormat    :String
    let secretKeyId  :String
    
    internal init(keyId: String, keyFormat: String, secretKeyId:String, typeCode: String? = nil, uniqueId: String? = nil) {
        self.keyId         = keyId
        self.keyFormat     = keyFormat
        self.secretKeyId   = secretKeyId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    private enum CodingKeys:String ,CodingKey{
        case secretKey
        case algorithm
        case secretKeyId
    }
    
    override func encode(to encoder: Encoder) throws {
        
    }
}

struct GetDefineSecretKeyResponse:Decodable{
    let keyId:String
    let algorithm:String
    let clientId:String
}

struct GetPrivateKeyResponse:Decodable{
    let keyId:String
    let algorithm:String
    let clientId:String
    let privateKey:String
    let publicKey:String
    let keyFormat:String
}
