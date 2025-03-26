import Foundation
import XCTest


final class DateTests: XCTestCase {

    func testGetTime() {
        // Given
        let value = Date(timeIntervalSince1970: 1681314000)
        // When
        let result = value.getTime(localIdentifire: Locale.current.identifier)
        // Then
        if Locale.current.identifier.lowercased() == "en_us" {
            XCTAssertEqual(result, "3:40 PM", "Expected the time string to be '3:40 PM' but it's \(result)")
        } else if Locale.current.identifier.lowercased().contains("ir") {
            XCTAssertEqual(result, "15:40", "Expected the time string to be '15:40' but it's \(result)")
        } else if Locale.current.identifier.lowercased().contains("de") {
            XCTAssertEqual(result, "15:40", "Expected the time string to be '15:40' but it's \(result)")
        }
    }

    func testGetDate() {
        // Given
        let value = Date(timeIntervalSince1970: 1681314000)
        // When
        let result = value.getDate(localIdentifire: Locale.current.identifier)
        // Then
        if Locale.current.identifier.lowercased() == "en_us" {
            XCTAssertEqual(result, "2023-04-12", "Expected the date string to be '2023-04-12' but it's \(result)")
        } else if Locale.current.identifier.lowercased().contains("ir") {
            XCTAssertEqual(result, "1402-01-23", "Expected the date string to be '1402-01-23' but it's \(result)")
        } else if Locale.current.identifier.lowercased().contains("de") {
            XCTAssertEqual(result, "2023-04-12", "Expected the date string to be '2023-04-12' but it's \(result)")
        }
    }

    //LEFT=====CENTER====RIGHT
    func testIsBetween_WhenDateIsBetweenTowOtherDate_returnTrue() {
        // Given
        let now = Date()
        let left = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let center = Calendar.current.date(byAdding: .day, value: 5, to: now)!
        let right = Calendar.current.date(byAdding: .day, value: 10, to: now)!
        // When
        let result = center.isBetweeen(date: left, andDate: right)
        // Then
        XCTAssertTrue(result, "Expected the result to be true but it's \(result)")
    }

    func testIsBetween_WhenDateIsNotBetweenTowOtherDate_returnTrue() {
        // Given
        let now = Date()
        let left = Calendar.current.date(byAdding: .day, value: 8, to: now)!
        let center = Calendar.current.date(byAdding: .day, value: 5, to: now)!
        let right = Calendar.current.date(byAdding: .day, value: 10, to: now)!
        // When
        let result = center.isBetweeen(date: left, andDate: right)
        // Then
        XCTAssertFalse(result, "Expected the result to be flase but it's \(result)")
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testTimeAgoCondense() {
        // Given
        let date = Date(timeIntervalSince1970: 1681314000000)
        // When
        let result = date.timeAgoSinceDateCondense()
        // Then
        if Locale.current.identifier.lowercased() == "en_us" {
            XCTAssertEqual(result, "Sep 19, 48", "Expected the string to be 'Sep 19, 48' but it's \(String(describing: result))")
        } else if Locale.current.identifier.lowercased().contains("ir") {
            XCTAssertEqual(result, "Mehr 02, 27 AP", "Expected the string to be 'Mehr 02, 27 AP' but it's \(String(describing: result))")
        } else if Locale.current.identifier.lowercased().contains("de") {
            XCTAssertEqual(result, "19. Sept. 48", "Expected the string to be '19. Sept. 48' but it's \(String(describing: result))")
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testTimeAgoCondense_whenDateIsToday_returnHourAndMinuteOnly() {
        // Given
        let date = Date()
        // When
        let result = date.timeAgoSinceDateCondense()
        // Then
        XCTAssertFalse(result?.contains(",") == true, "Expected the string does not contain ',' but it's \(String(describing: result))")
        XCTAssertTrue(result?.contains(":") == true, "Expected the string contains ':' but it's \(String(describing: result))")
        if Locale.current.identifier.lowercased() == "en_us" {
            XCTAssertTrue(result?.contains("AM") == true || result?.contains("PM") == true, "Expected the string contains 'AM' OR 'PM' but it's \(String(describing: result))")
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testTimeAgoCondense_whenDateIsInsideTheCurrentMonth_returnWeekDayHourAndMinuteOnly() {
        // Given
        let calendar = Calendar(identifier: .gregorian)
        let startOfTheWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: Date()).date!
        let oneDayLaterInTheSameWeek = calendar.date(byAdding: .day, value: 1, to: startOfTheWeek)!
        // When
        let result = oneDayLaterInTheSameWeek.timeAgoSinceDateCondense()
        // Then
        if !Locale.current.identifier.lowercased().contains("de") {
            XCTAssertTrue(result?.contains(" ") == true, "Expected the string contains an space but it's \(String(describing: result))")
        }
        XCTAssertTrue(result?.contains(":") == true, "Expected the string contains ':' but it's \(String(describing: result))")
        XCTAssertFalse(result?.contains("AM") == true || result?.contains("PM") == true, "Expected the string does not contain 'AM' OR 'PM' but it's \(String(describing: result))")
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testTimeAgoCondense_whenDateIsInsideTheCurrentYear_returnWeekDayHourAndMinuteOnly() {
        // Given
        let calendar = Calendar(identifier: .gregorian)
        let startOfTheYear = Calendar.current.dateComponents([.calendar, .year], from: Date()).date!
        let oneDayLaterInTheSameYear = calendar.date(byAdding: .day, value: 1, to: startOfTheYear)!
        // When
        let result = oneDayLaterInTheSameYear.timeAgoSinceDateCondense(local: Locale.current)
        let spaceCount = result?.split(separator: " ").count ?? 0
        // Then
        if Locale.current.identifier.lowercased() == "en_us" {
            XCTAssertEqual(spaceCount, 4,  "Expected the string contains 4 spaces between Month, Day and Time and `at` but it's \(String(describing: result))")
        } else if Locale.current.identifier.lowercased().contains("ir")  {
            XCTAssertEqual(spaceCount, 4,  "Expected the string contains 4 spaces between Month, Day and Time and `at` but it's \(String(describing: result))")
        } else if Locale.current.identifier.lowercased().contains("de") {
            XCTAssertEqual(spaceCount, 3,  "Expected the string contains 3 spaces between Month, Day and Time and `at` but it's \(String(describing: result))")
        }
        XCTAssertTrue(result?.contains(":") == true, "Expected the string contains ':' but it's \(String(describing: result))")
        XCTAssertFalse(result?.contains("AM") == true || result?.contains("PM") == true,  "Expected the string does not contain 'AM' OR 'PM' but it's \(String(describing: result))")
    }

    func testMillisecondsSince1970() {
        // Given
        let value = Date(timeIntervalSince1970: 1681314000000)
        // When
        let result = value.millisecondsSince1970
        // Then
        XCTAssertEqual(result, 1681314000000 * 1000, accuracy: 0, "Expected the int to be equal to 1681314000000000 but it's \(String(describing: result))")
    }

    func testInitMillisecons() {
        // Given
        let value = Date(milliseconds: 1681314000000)
        // When
        let result = value.timeIntervalSince1970
        // Then
        XCTAssertEqual(result, 1681314000000 / 1000, accuracy: 0, "Expected the int to be equal to 1681314000 but it's \(String(describing: result))")
    }

    func testTimerString() {
        // Given
        let value = Calendar.current.date(byAdding: .minute, value: -5, to: .init())!
        // When
        let result = value.timerString
        // Then
        XCTAssertEqual(result?.count, 8, "Expected the string to have format with 8 character like 12:23:34 but it's \(String(describing: result))")
    }
}
