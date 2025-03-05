//
// Number+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public protocol Arritmatic {}
extension Int: Arritmatic {}
extension UInt: Arritmatic {}
extension Float: Arritmatic {}
extension Double: Arritmatic {
    static let unit: [String] = { ["General.KB", "General.MB", "General.GB"] }()
}

nonisolated(unsafe) private var nf = NumberFormatter()
let dateFormatterComp = DateComponentsFormatter()

public extension Numeric {
    func toSizeString(locale: Locale = .current, bundle: Bundle) -> String? {
        if let number = self as? NSNumber {
            let value = Double(truncating: number)
            if value < 1024 {
                let locaizedByte: String
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    locaizedByte = String(localized: .init("General.Byte"), bundle: bundle)
                } else {
                    locaizedByte = "General.Byte".localized(bundle: bundle)
                }
                return "\(value) \(locaizedByte)"
            }
            let exp = Int(log2(value) / log2(1024.0))
            let unitIndex = max(0, exp - 1)
            let unit: String
            if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                unit = String(localized: .init(Double.unit[unitIndex]), bundle: bundle)
            } else {
                unit = Double.unit[unitIndex].localized(bundle: bundle)
            }
            let number = value / pow(1024, Double(exp))
            if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                return "\(number.formatted(.number.precision(.fractionLength(1)).locale(locale))) \(unit)"
            } else {
                let localizedNumber = number.localNumber(locale: locale) ?? ""
                return "\(String(format: "%.1f", localizedNumber)) \(unit)"
            }
        } else {
            return nil
        }
    }

    func timerString(locale: Locale = .current) -> String? {
        guard let seconds = self as? NSNumber else { return nil }
        dateFormatterComp.calendar?.locale = locale
        dateFormatterComp.allowedUnits = Int(truncating: seconds) > 60 * 60 ? [.hour, .minute, .second] : [.minute, .second]
        dateFormatterComp.unitsStyle = .positional
        dateFormatterComp.zeroFormattingBehavior = .pad
        return dateFormatterComp.string(from: TimeInterval(Int(truncating: seconds)))
    }
    
    func timerStringTripleSection(locale: Locale = .current) -> String? {
        guard let seconds = self as? NSNumber else { return nil }
        dateFormatterComp.calendar?.locale = locale
        dateFormatterComp.allowedUnits = [.hour, .minute, .second]
        dateFormatterComp.unitsStyle = .positional
        dateFormatterComp.zeroFormattingBehavior = .pad
        return dateFormatterComp.string(from: TimeInterval(Int(truncating: seconds)))
    }

    func localNumber(locale: Locale = .current) -> String? {
        guard let nsNumber = self as? NSNumber else { return nil }
        nf.locale = locale
        return nf.string(from: nsNumber)
    }
}

public extension UInt {
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }
}

@propertyWrapper
struct Constraint<Value: Comparable> {
    private var value: Value
    private var range: ClosedRange<Value>

    public var wrappedValue: Value {
        get {
            max(min(value, range.upperBound), range.lowerBound)
        }
        set {
            value = newValue
        }
    }

    public init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        value = wrappedValue
        self.range = range
    }
}
