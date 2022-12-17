//
// StringEX.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/16/22

import CommonCrypto
import CryptoKit
import Foundation

extension String {
    var md5: String? {
        if #available(iOS 13.0, *) {
            let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
            return digest.map { String(format: "%02hhx", $0) }.joined()
        } else {
            let length = Int(CC_MD5_DIGEST_LENGTH)
            let messageData = data(using: .utf8)!
            var digestData = Data(count: length)

            _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
                messageData.withUnsafeBytes { messageBytes -> UInt8 in
                    if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                        let messageLength = CC_LONG(messageData.count)
                        CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                    }
                    return 0
                }
            }
            return digestData.map { String(format: "%02hhx", $0) }.joined()
        }
    }

    public func removeBackSlashes() -> String {
        replacingOccurrences(of: "\\\\\"", with: "\"")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\\\\"", with: "\"")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\"{", with: "\n{")
            .replacingOccurrences(of: "}\"", with: "}\n")
            .replacingOccurrences(of: "\"[", with: "\n[")
            .replacingOccurrences(of: "]\"", with: "]\n")
    }

    var localized: String {
        NSLocalizedString(self, bundle: Bundle.moduleBundle, comment: "")
    }

    func toURLCompoenentString(encodable: Encodable) -> String? {
        var queryStringUrl = self
        if let parameters = try? encodable.asDictionary(), parameters.count > 0 {
            var urlComp = URLComponents(string: self)!
            urlComp.queryItems = []
            parameters.forEach { key, value in
                urlComp.queryItems?.append(URLQueryItem(name: key, value: "\(value)"))
            }
            queryStringUrl = urlComp.url?.absoluteString ?? self
            return queryStringUrl
        }
        return nil
    }
}
