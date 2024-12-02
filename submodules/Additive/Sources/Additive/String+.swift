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

    func removeBackSlashes() -> String {
        replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: "\"{", with: "\n{")
            .replacingOccurrences(of: "}\"", with: "}\n")
            .replacingOccurrences(of: "\"[", with: "\n[")
            .replacingOccurrences(of: "]\"", with: "]\n")
    }

    /// Pretty print of a JSON.
    func prettyJsonString() -> String {
        let string = removeBackSlashes()
        let stringData = string.data(using: .utf8) ?? Data()
        if let jsonObject = try? JSONSerialization.jsonObject(with: stringData, options: .mutableContainers),
           let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        {
            let prettyString = String(data: prettyJsonData, encoding: .utf8) ?? ""
            return prettyString.removeBackSlashes()
        } else {
            return ""
        }
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
