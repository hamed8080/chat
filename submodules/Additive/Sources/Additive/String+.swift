//
// String+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 11/16/22

import CommonCrypto
import CryptoKit
import Foundation
import NaturalLanguage
#if canImport(UIKit)
    import UIKit
#endif

public extension String {
    var md5: String? {
        return md5NewVersion
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) internal var md5NewVersion: String {
        let digest = Insecure.MD5.hash(data: data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Decodes and pretty-prints JSON, including nested JSON strings within fields like `content`.
      func decodeNestedJson() -> String {
          guard let data = self.data(using: .utf8) else { return self }

          do {
              // Parse the top-level JSON object
              let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)

              // Recursively process and decode any nested JSON strings
              let decodedObject = recursivelyDecode(jsonObject)

              // Convert the fully decoded object back to a pretty-printed JSON string
              let prettyJsonData = try JSONSerialization.data(withJSONObject: decodedObject, options: .prettyPrinted)
              return String(data: prettyJsonData, encoding: .utf8) ?? self
          } catch {
              // Return the original string if any errors occur
#if DEBUG
              print("Error decoding JSON: \(error)")
#endif              
              return self
          }
      }

      /// Recursively decodes nested JSON strings.
      private func recursivelyDecode(_ json: Any) -> Any {
          if let jsonString = json as? String, let jsonData = jsonString.data(using: .utf8) {
              // Try to decode the string as JSON
              if let nestedJsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) {
                  // Recursively decode the nested JSON object
                  return recursivelyDecode(nestedJsonObject)
              }
              return jsonString // If decoding fails, return the original string
          } else if let jsonArray = json as? [Any] {
              // Process each element in the array
              return jsonArray.map { recursivelyDecode($0) }
          } else if let jsonDict = json as? [String: Any] {
              // Process each value in the dictionary
              var decodedDict = [String: Any]()
              for (key, value) in jsonDict {
                  decodedDict[key] = recursivelyDecode(value)
              }
              return decodedDict
          }

          // If the value is not a string, array, or dictionary, return it as is
          return json
      }

    /// Pretty print of a JSON.
    func prettyJsonString() -> String {
        return decodeNestedJson()
    }

    func localized(bundle: Bundle = .main) -> String {
        NSLocalizedString(self, bundle: bundle, comment: "")
    }

    #if canImport(UIKit)
        func widthOfString(usingFont font: UIKit.UIFont) -> CGFloat {
            let fontAttributes = [NSAttributedString.Key.font: font]
            return NSString(string: self).size(withAttributes: fontAttributes).width
        }
    #endif

    var isEnglishString: Bool {
        if #available(iOS 12.0, macOS 10.14, *) {
            let languageRecognizer = NLLanguageRecognizer()
            languageRecognizer.processString(self)
            guard let code = languageRecognizer.dominantLanguage?.rawValue else { return true }
            languageRecognizer.reset()
            return code != "fa" && code != "ar"
        } else {
            return true
        }
    }

    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }

    func replaceRTLNumbers() -> String {
        let numbers = ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹"]
        var string = self
        for (index, number) in numbers.enumerated() {
           string = string.replacingOccurrences(of: number, with: String(index))
        }
        return string
    }
}

public extension Optional where Wrapped == any Collection {
    var isEmptyOrNil: Bool {
        self == nil || self?.isEmpty == true
    }
}

public extension String? {
    var isEmptyOrNil: Bool {
        self == nil || self?.isEmpty == true
    }
}

@propertyWrapper
public struct AllCaps {
    public var wrappedValue: String {
        didSet {
            wrappedValue = wrappedValue.uppercased()
        }
    }

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct CaseInsensitive {
    public var wrappedValue: String {
        didSet {
            wrappedValue = wrappedValue.lowercased()
        }
    }

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct Trimmed {
    private var text: String
    public var wrappedValue: String {
        get {
            text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            text = newValue
        }
    }

    public init(wrappedValue: String) {
        text = wrappedValue
    }
}

public extension Character {
    var isEnglishCharacter: Bool {
        guard let scalar = unicodeScalars.first else { return true }
        let normalArabicSet = CharacterSet(charactersIn: "\u{0600}"..."\u{06FF}")
        let supplementArabicSet = CharacterSet(charactersIn: "\u{0750}"..."\u{077F}")
        let extendedArabicSet = CharacterSet(charactersIn: "\u{08A0}"..."\u{08FF}")
        let arabicPresentationFormA = CharacterSet(charactersIn: "\u{FB50}"..."\u{FDFF}")
        let arabicPresentationFormsB = CharacterSet(charactersIn: "\u{FE70}"..."\u{FEFF}")
        // Joiners and Persian punctuation
        let joiners = CharacterSet(charactersIn: "\u{200C}"..."\u{200D}")
        let persianQuotes = CharacterSet(charactersIn: "\u{00AB}\u{00BB}") // « and »

        let persianExtraPunctuations = CharacterSet(charactersIn: "()=-_•|~<>&\\:؛!؟.,“”‘’\"'/+*^#{}][")

        let set = [
            normalArabicSet,
            supplementArabicSet,
            extendedArabicSet,
            arabicPresentationFormA,
            arabicPresentationFormsB,
            joiners,
            persianQuotes,
            persianExtraPunctuations
        ]
       
        let isRTL = set.contains(where: { $0.contains(scalar) })
        return !isRTL
    }
}

public extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
