//
// Date+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public extension Date {
    static var formatter = DateFormatter()
    static let pCal = Calendar(identifier: .persian)

    func getTime(localIdentifire: String = "en_US", withAbbrevation: String? = nil) -> String {
        let formatter = Date.formatter
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: localIdentifire)
        if let withAbbrevation = withAbbrevation {
            formatter.timeZone = .init(abbreviation: withAbbrevation)
        }
        return formatter.string(from: self)
    }

    func getDate(localIdentifire: String = "en_US", withAbbrevation: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: localIdentifire)
        formatter.dateFormat = "yyyy-MM-dd"
        if let withAbbrevation = withAbbrevation {
            formatter.timeZone = .init(abbreviation: withAbbrevation)
        }
        return formatter.string(from: self)
    }

    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        date1.compare(self) == compare(date2)
    }

    /// EEEE Name od the day = Monday
    /// MMM: Name of the month = November
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) func timeAgoSinceDateCondense(local: Locale = .current) -> String? {
        Date.formatter.locale = local
        let isPersian = local.identifier == "fa_IR"
        let cal = isPersian ? Date.pCal : Calendar.current

        if cal.isDateInToday(self) {
            Date.formatter.dateFormat = "HH:mm"
        } else if let diff = cal.dateComponents([.day], from: self, to: .now).day, diff < 7 {
            Date.formatter.dateFormat = "EEEE HH:mm"
        } else if cal.isDate(self, equalTo: .now, toGranularity: .year) {
            Date.formatter.dateFormat = "MM-dd HH:mm"
        } else {
            Date.formatter.dateFormat = "yyyy-MM-dd"
        }
        return Date.formatter.string(from: self)
    }

    /// EEEE Name of the day = Monday
    /// MMM: Name of the month = November
    /// PS: Do not use shared dateFormatter in this calss it will lead to problems in displaying the right date format.
    private static let dtf = DateFormatter()
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) func timeOrDate(local: Locale = .current) -> String? {
        Date.dtf.locale = local
        let isPersian = local.identifier == "fa_IR"
        var cal = isPersian ? Date.pCal : Calendar.current
        cal.locale = local
        if cal.isDateInToday(self) {
            Date.dtf.dateFormat = "HH:mm"
        } else if let diff = cal.dateComponents([.day], from: self, to: .now).day, diff < 7 {
            Date.dtf.dateFormat = "EEEE"
        } else if cal.isDate(self, equalTo: .now, toGranularity: .year) {
            Date.dtf.dateFormat = "yyyy-M-d"
        } else {
            Date.dtf.dateFormat = "yyyy-M-d"
        }
        return Date.dtf.string(from: self)
    }

    // It will return "15 October 2024"
    func dayMonthNameYear(local: Locale = .current) -> String? {
        Date.dtf.locale = local
        let isPersian = local.identifier == "fa_IR"
        var cal = isPersian ? Date.pCal : Calendar.current
        cal.locale = local

        Date.dtf.dateFormat = "d MMM yyyy"
        return Date.dtf.string(from: self)
    }

    var millisecondsSince1970: Int64 {
        Int64((timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    /// It will make a timer output for a start point in time. `Date().timerString => 00:00:01`
    var timerString: String? {
        let interval = Date().timeIntervalSince1970 - timeIntervalSince1970
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return autoreleasepool {
            return formatter.string(from: interval)
        }
    }

    /// EEEE Name od the day = Monday
    /// d: The number of the day in a weak, and we use single 'd' instead of double 'dd' because we don't want zero like 2023/09/02 we want 2023/9/2.
    /// M: The number of the month, and we use single 'M' instead of double 'MM' because we don't want zero like 2023/09/02 we want 2023/9/2.
    /// MMM: Name of the month = November
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) func yearCondence(local: Locale = .current) -> String? {
        Date.formatter.locale = local

        let sectionYear = Calendar.current.component(.year, from: self)
        let thisYear = Calendar.current.component(.year, from: .now)
        let isThisYear = thisYear == sectionYear
        if Calendar.current.isDate(self, equalTo: .now, toGranularity: .weekOfMonth) {
            Date.formatter.dateFormat = "EEEE"
        } else if isThisYear {
            Date.formatter.dateFormat = "EEEE d MMM"
        } else {
            Date.formatter.dateFormat = "yyyy-M-d"
        }
        let string = Date.formatter.string(from: self)
        return autoreleasepool {
            return string.replacingOccurrences(of: "\"", with: "")
        }
    }
}
