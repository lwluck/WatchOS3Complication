//
//  NSDate+Utilities.swift
//  Bullion Stacker
//
//  Created by Lloyd Luck on 12/24/15.
//  Copyright © 2015 Lloyd Luck. All rights reserved.
//

import UIKit

// DotNet: "/Date(1268123281843)/"
let DefaultFormat = "EEE MMM dd HH:mm:ss Z yyyy"
let RSSFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ" // "Fri, 09 Sep 2011 15:26:08 +0200"
let AltRSSFormat = "d MMM yyyy HH:mm:ss ZZZ" // "09 Sep 2011 15:26:08 +0200"

public enum ISO8601Format: String {
    
    case Year = "yyyy" // 1997
    case YearMonth = "yyyy-MM" // 1997-07
    case Date = "yyyy-MM-dd" // 1997-07-16
    case DateTime = "yyyy-MM-dd'T'HH:mmZ" // 1997-07-16T19:20+01:00
    case DateTimeSec = "yyyy-MM-dd'T'HH:mm:ssZ" // 1997-07-16T19:20:30+01:00
    case DateTimeMilliSec = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 1997-07-16T19:20:30.45+01:00
    
    init(dateString:String) {
        switch dateString.characters.count {
        case 4:
            self = ISO8601Format(rawValue: ISO8601Format.Year.rawValue)!
        case 7:
            self = ISO8601Format(rawValue: ISO8601Format.YearMonth.rawValue)!
        case 10:
            self = ISO8601Format(rawValue: ISO8601Format.Date.rawValue)!
        case 22:
            self = ISO8601Format(rawValue: ISO8601Format.DateTime.rawValue)!
        case 25:
            self = ISO8601Format(rawValue: ISO8601Format.DateTimeSec.rawValue)!
        default:// 28:
            self = ISO8601Format(rawValue: ISO8601Format.DateTimeMilliSec.rawValue)!
        }
    }
}

public enum DateFormat {
    case iso8601(ISO8601Format?), dotNet, rss, altRSS, custom(String)
}

public extension Date {
    
    // MARK: Intervals In Seconds
    fileprivate static func minuteInSeconds() -> Double { return 60 }
    fileprivate static func hourInSeconds() -> Double { return 3600 }
    fileprivate static func dayInSeconds() -> Double { return 86400 }
    fileprivate static func weekInSeconds() -> Double { return 604800 }
    fileprivate static func yearInSeconds() -> Double { return 31556926 }
    
    // MARK: Components
    private static func componentFlags() -> Set<Calendar.Component> { return [Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekday, Calendar.Component.weekOfYear, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second, Calendar.Component.day, Calendar.Component.weekdayOrdinal, Calendar.Component.weekOfYear] }
    
    private static func components(fromDate: Date) -> DateComponents! {
        return Calendar.current.dateComponents(Date.componentFlags(), from: fromDate)
    }
    
    fileprivate func easternTimeComponents() -> DateComponents {
        let components = Date.components(fromDate: self)!
        (components as NSDateComponents).timeZone = TimeZone(secondsFromGMT: -18000)
        return components
    }
    
    fileprivate func components() -> DateComponents  {
        return Date.components(fromDate: self)!
    }
    
    // MARK: Comparing Dates
    
    /**
    Returns true if dates are equal while ignoring time.
    
    - Parameter date: The Date to compare.
    */
    func isEqualToDateIgnoringTime(_ date: Date) -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: date)
        return ((comp1!.year == comp2!.year) && (comp1!.month == comp2!.month) && (comp1!.day == comp2!.day))
    }
    
    /**
     Returns Returns true if date is today.
     */
    func isToday() -> Bool
    {
        return self.isEqualToDateIgnoringTime(Date())
    }
    
    /**
     Returns true if date is tomorrow.
     */
    func isTomorrow() -> Bool
    {
        return self.isEqualToDateIgnoringTime(Date().dateByAddingDays(1))
    }
    
    /**
     Returns true if date is yesterday.
     */
    func isYesterday() -> Bool
    {
        return self.isEqualToDateIgnoringTime(Date().dateBySubtractingDays(1))
    }
    
    /**
     Returns true if date are in the same week.
     
     - Parameter date: The date to compare.
     */
    func isSameWeekAsDate(_ date: Date) -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: date)
        // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
        if comp1?.weekOfYear != comp2?.weekOfYear {
            return false
        }
        // Must have a time interval under 1 week
        return abs(self.timeIntervalSince(date)) < Date.weekInSeconds()
    }
    
    /**
     Returns true if date is this week.
     */
    func isThisWeek() -> Bool
    {
        return self.isSameWeekAsDate(Date())
    }
    
    /**
     Returns true if date is next week.
     */
    func isNextWeek() -> Bool
    {
        let interval: TimeInterval = Date().timeIntervalSinceReferenceDate + Date.weekInSeconds()
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return self.isSameWeekAsDate(date)
    }
    
    /**
     Returns true if date is last week.
     */
    func isLastWeek() -> Bool
    {
        let interval: TimeInterval = Date().timeIntervalSinceReferenceDate - Date.weekInSeconds()
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return self.isSameWeekAsDate(date)
    }
    
    /**
     Returns true if dates are in the same year.
     
     - Parameter date: The date to compare.
     */
    func isSameYearAsDate(_ date: Date) -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: date)
        return (comp1!.year == comp2!.year)
    }
    
    /**
     Returns true if date is this year.
     */
    func isThisYear() -> Bool
    {
        return self.isSameYearAsDate(Date())
    }
    
    /**
     Returns true if date is next year.
     */
    func isNextYear() -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: Date())
        return (comp1!.year! == comp2!.year! + 1)
    }
    
    /**
     Returns true if date is last year.
     */
    func isLastYear() -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: Date())
        return (comp1!.year! == comp2!.year! - 1)
    }
    
    /**
     Returns true if date is earlier than date.
     
     - Parameter date: The date to compare.
     */
    func isEarlierThanDate(_ date: Date) -> Bool
    {
        return (self as NSDate).earlierDate(date) == self
    }
    
    /**
     Returns true if date is later than date.
     
     - Parameter date: The date to compare.
     */
    func isLaterThanDate(_ date: Date) -> Bool
    {
        return (self as NSDate).laterDate(date) == self
    }
    
    /**
     Returns true if date is in future.
     */
    func isInFuture() -> Bool
    {
        return self.isLaterThanDate(Date())
    }
    
    /**
     Returns true if date is in past.
     */
    func isInPast() -> Bool
    {
        return self.isEarlierThanDate(Date())
    }
    
    
    // MARK: Adjusting Dates
    
    /**
    Creates a new date by a adding days.
    
    - Parameter days: The number of days to add.
    - Returns A new date object.
    */
    func dateByAddingDays(_ days: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.day = days
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /**
     Creates a new date by a substracting days.
     
     - Parameter days: The number of days to substract.
     - Returns A new date object.
     */
    func dateBySubtractingDays(_ days: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.day = (days * -1)
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /**
     Creates a new date by a adding hours.
     
     - Parameter days: The number of hours to add.
     - Returns A new date object.
     */
    func dateByAddingHours(_ hours: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.hour = hours
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /**
     Creates a new date by substracting hours.
     
     - Parameter days: The number of hours to substract.
     - Returns A new date object.
     */
    func dateBySubtractingHours(_ hours: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.hour = (hours * -1)
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /**
     Creates a new date by adding minutes.
     
     - Parameter days: The number of minutes to add.
     - Returns A new date object.
     */
    func dateByAddingMinutes(_ minutes: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.minute = minutes
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /**
     Creates a new date by substracting minutes.
     
     - Parameter days: The number of minutes to add.
     - Returns A new date object.
     */
    func dateBySubtractingMinutes(_ minutes: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.minute = (minutes * -1)
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /**
     Creates a new date by adding seconds.
     
     - Parameter seconds: The number of seconds to add.
     - Returns A new date object.
     */
    func dateByAddingSeconds(_ seconds: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.second = seconds
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /**
     Creates a new date by substracting seconds.
     
     - Parameter days: The number of seconds to substract.
     - Returns A new date object.
     */
    func dateBySubtractingSeconds(_ seconds: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.second = (seconds * -1)
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /**
     Creates a new date from the start of the day.
     
     - Returns A new date object.
     */
    func dateAtStartOfDay() -> Date
    {
        var components = self.components()
        components.hour = 0
        components.minute = 0
        components.second = 0
        return NSCalendar.current.date(from: components)!
    }
    
    /**
     Creates a new date from the end of the day.
     
     - Returns A new date object.
     */
    func dateAtEndOfDay() -> Date
    {
        var components = self.components()
        components.hour = 23
        components.minute = 59
        components.second = 59
        return NSCalendar.current.date(from: components)!
    }
    
    /**
     Creates a new date from the start of the week.
     
     - Returns A new date object.
     */
    func dateAtStartOfWeek() -> Date
    {
        let flags: Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekOfYear, Calendar.Component.weekday]
        var components = Calendar.current.dateComponents(flags, from: self)
        components.weekday = NSCalendar.current.firstWeekday
        components.hour = 0
        components.minute = 0
        components.second = 0
        return NSCalendar.current.date(from: components)!
    }
    
    /**
     Creates a new date from the end of the week.
     
     - Returns A new date object.
     */
    func dateAtEndOfWeek() -> Date
    {
        let flags: Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekOfYear, Calendar.Component.weekday]
        var components = NSCalendar.current.dateComponents(flags, from: self)
        components.weekday = NSCalendar.current.firstWeekday + 6
        components.hour = 0
        components.minute = 0
        components.second = 0
        return NSCalendar.current.date(from: components)!
    }
    
    /**
     Creates a new date from the first day of the month
     
     - Returns A new date object.
     */
    func dateAtTheStartOfMonth() -> Date
    {
        //Create the date components
        var components = self.components()
        components.day = 1
        //Builds the first day of the month
        let firstDayOfMonthDate :Date = NSCalendar.current.date(from: components)!
        
        return firstDayOfMonthDate
        
    }
    
    /**
     Creates a new date from the last day of the month
     
     - Returns A new date object.
     */
    func dateAtTheEndOfMonth() -> Date {
        
        //Create the date components
        var components = self.components()
        //Set the last day of this month
        components.month? += 1
        components.day = 0
        
        //Builds the first day of the month
        let lastDayOfMonth :Date = NSCalendar.current.date(from: components)!
        
        return lastDayOfMonth
        
    }
    
    /**
     Creates a new date based on tomorrow.
     
     - Returns A new date object.
     */
    static func tomorrow() -> Date
    {
        return Date().dateByAddingDays(1).dateAtStartOfDay()
    }
    
    /**
     Creates a new date based on yesterdat.
     
     - Returns A new date object.
     */
    static func yesterday() -> Date
    {
        return Date().dateBySubtractingDays(1).dateAtStartOfDay()
    }
    
    
    // MARK: Retrieving Intervals
    
    /**
    Gets the number of seconds after a date.
    
    - Parameter date: the date to compare.
    - Returns The number of seconds
    */
    func secondsAfterDate(_ date: Date) -> Int
    {
        return Int(self.timeIntervalSince(date))
    }
    
    /**
     Gets the number of seconds before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of seconds
     */
    func secondsBeforeDate(_ date: Date) -> Int
    {
        return Int(date.timeIntervalSince(self))
    }
    
    /**
     Gets the number of minutes after a date.
     
     - Parameter date: the date to compare.
     - Returns The number of minutes
     */
    func minutesAfterDate(_ date: Date) -> Int
    {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.minuteInSeconds())
    }
    
    /**
     Gets the number of minutes before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of minutes
     */
    func minutesBeforeDate(_ date: Date) -> Int
    {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.minuteInSeconds())
    }
    
    /**
     Gets the number of hours after a date.
     
     - Parameter date: The date to compare.
     - Returns The number of hours
     */
    func hoursAfterDate(_ date: Date) -> Int
    {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.hourInSeconds())
    }
    
    /**
     Gets the number of hours before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of hours
     */
    func hoursBeforeDate(_ date: Date) -> Int
    {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.hourInSeconds())
    }
    
    /**
     Gets the number of days after a date.
     
     - Parameter date: The date to compare.
     - Returns The number of days
     */
    func daysAfterDate(_ date: Date) -> Int
    {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.dayInSeconds())
    }
    
    /**
     Gets the number of days before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of days
     */
    func daysBeforeDate(_ date: Date) -> Int
    {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.dayInSeconds())
    }
    
    
    // MARK: Decomposing Dates
    
    /**
    Returns the nearest hour.
    */
    func nearestHour () -> Int {
        let halfHour = Date.minuteInSeconds() * 30
        var interval = self.timeIntervalSinceReferenceDate
        if  self.seconds() < 30 {
            interval -= halfHour
        } else {
            interval += halfHour
        }
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return date.hour()
    }
    /**
     Returns the year component.
     */
    func year () -> Int { return self.easternTimeComponents().year!  }
    /**
     Returns the month component.
     */
    func month () -> Int { return self.easternTimeComponents().month! }
    /**
     Returns the week of year component.
     */
    func week () -> Int { return self.easternTimeComponents().weekOfYear! }
    /**
     Returns the day component.
     */
    func day () -> Int { return self.easternTimeComponents().day! }
    /**
     Returns the hour component.
     */
    func hour () -> Int { return self.easternTimeComponents().hour! }
    /**
     Returns the minute component.
     */
    func minute () -> Int { return self.easternTimeComponents().minute! }
    /**
     Returns the seconds component.
     */
    func seconds () -> Int { return self.easternTimeComponents().second! }
    /**
     Returns the weekday component.
     */
    func weekday () -> Int { return self.easternTimeComponents().weekday! }
    /**
     Returns the nth days component. e.g. 2nd Tuesday of the month is 2.
     */
    func nthWeekday () -> Int { return self.easternTimeComponents().weekdayOrdinal! }
    /**
     Returns the days of the month.
     */
    func monthDays () -> Int { return Calendar.current.range(of: Calendar.Component.weekday, in: Calendar.Component.month, for: self)!.count }
    /**
     Returns the first day of the week.
     */
    func firstDayOfWeek () -> Int {
        let distanceToStartOfWeek = Date.dayInSeconds() * Double(self.components().weekday! - 1)
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek
        return Date(timeIntervalSinceReferenceDate: interval).day()
    }
    /**
     Returns the last day of the week.
     */
    func lastDayOfWeek () -> Int {
        let distanceToStartOfWeek = Date.dayInSeconds() * Double(self.components().weekday! - 1)
        let distanceToEndOfWeek = Date.dayInSeconds() * Double(7)
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek + distanceToEndOfWeek
        return Date(timeIntervalSinceReferenceDate: interval).day()
    }
    /**
     Returns true if a weekday.
     */
    func isWeekday() -> Bool {
        return !self.isWeekend()
    }
    /**
     Returns true if weekend.
     */
    func isWeekend() -> Bool {
        let range = NSCalendar.current.maximumRange(of: Calendar.Component.weekday)
        return (self.weekday() == range?.lowerBound || self.weekday() == range?.count)
    }
    
    
    // MARK: To String
    
    /**
    A string representation using short date and time style.
    */
    func toString() -> String {
        return self.toString(dateStyle: .short, timeStyle: .short, doesRelativeDateFormatting: false)
    }
    
    /**
     A string representation based on a format.
     
     - Parameter format: The format of date can be .ISO8601(.ISO8601Format?), .DotNet, .RSS, .AltRSS or Custom(FormatString).
     - Returns The date string representation
     */
    func toString(format: DateFormat) -> String
    {
        var dateFormat: String
        switch format {
        case .dotNet:
            let offset = NSTimeZone.default.secondsFromGMT() / 3600
            let nowMillis = 1000 * self.timeIntervalSince1970
            return  "/Date(\(nowMillis)\(offset))/"
        case .iso8601(let isoFormat):
            dateFormat = (isoFormat != nil) ? isoFormat!.rawValue : ISO8601Format.DateTimeMilliSec.rawValue
        case .rss:
            dateFormat = RSSFormat
        case .altRSS:
            dateFormat = AltRSSFormat
        case .custom(let string):
            dateFormat = string
        }
        let formatter = Date.formatter(format: dateFormat)
        return formatter.string(from: self)
    }
    
    /**
     A string representation based on custom style.
     
     - Parameter dateStyle: The date style to use.
     - Parameter timeStyle: The time style to use.
     - Parameter doesRelativeDateFormatting: Enables relative date formatting.
     - Returns A string representation of the date.
     */
    func toString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, doesRelativeDateFormatting: Bool = false) -> String
    {
        let formatter = Date.formatter(dateStyle: dateStyle, timeStyle: timeStyle, doesRelativeDateFormatting: doesRelativeDateFormatting)
        return formatter.string(from: self)
    }
    
    /**
     A string representation based on a relative time language. i.e. just now, 1 minute ago etc..
     */
    func relativeTimeToString() -> String
    {
        let time = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        
        let seconds = now - time
        let minutes = round(seconds/60)
        let hours = round(minutes/60)
        let days = round(hours/24)
        
        if seconds < 10 {
            return NSLocalizedString("just now", comment: "Show the relative time from a date")
        } else if seconds < 60 {
            let relativeTime = NSLocalizedString("%.f seconds ago", comment: "Show the relative time from a date")
            return String(format: relativeTime, seconds)
        }
        
        if minutes < 60 {
            if minutes == 1 {
                return NSLocalizedString("1 minute ago", comment: "Show the relative time from a date")
            } else {
                let relativeTime = NSLocalizedString("%.f minutes ago", comment: "Show the relative time from a date")
                return String(format: relativeTime, minutes)
            }
        }
        
        if hours < 24 {
            if hours == 1 {
                return NSLocalizedString("1 hour ago", comment: "Show the relative time from a date")
            } else {
                let relativeTime = NSLocalizedString("%.f hours ago", comment: "Show the relative time from a date")
                return String(format: relativeTime, hours)
            }
        }
        
        if days < 7 {
            if days == 1 {
                return NSLocalizedString("1 day ago", comment: "Show the relative time from a date")
            } else {
                let relativeTime = NSLocalizedString("%.f days ago", comment: "Show the relative time from a date")
                return String(format: relativeTime, days)
            }
        }
        
        return self.toString()
    }
    
    /**
     A string representation of the weekday.
     */
    func weekdayToString() -> String {
        let formatter = Date.formatter()
        return formatter.weekdaySymbols[self.weekday()-1] as String
    }
    
    /**
     A short string representation of the weekday.
     */
    func shortWeekdayToString() -> String {
        let formatter = Date.formatter()
        return formatter.shortWeekdaySymbols[self.weekday()-1] as String
    }
    
    /**
     A very short string representation of the weekday.
     
     - Returns String
     */
    func veryShortWeekdayToString() -> String {
        let formatter = Date.formatter()
        return formatter.veryShortWeekdaySymbols[self.weekday()-1] as String
    }
    
    /**
     A string representation of the month.
     
     - Returns String
     */
    func monthToString() -> String {
        let formatter = Date.formatter()
        return formatter.monthSymbols[self.month()-1] as String
    }
    
    /**
     A short string representation of the month.
     
     - Returns String
     */
    func shortMonthToString() -> String {
        let formatter = Date.formatter()
        return formatter.shortMonthSymbols[self.month()-1] as String
    }
    
    /**
     A very short string representation of the month.
     
     - Returns String
     */
    func veryShortMonthToString() -> String {
        let formatter = Date.formatter()
        return formatter.veryShortMonthSymbols[self.month()-1] as String
    }
    
    
    // MARK: Static Cached Formatters
    
    /**
    Returns a cached static array of NSDateFormatters so that thy are only created once.
    */
    static var sharedDateFormatters: [String: DateFormatter] {
        return [String: DateFormatter]()
    }
    
    /**
     Returns a cached formatter based on the format, timeZone and locale. Formatters are cached in a singleton array using hashkeys generated by format, timeZone and locale.
     
     - Parameter format: The format to use.
     - Parameter timeZone: The time zone to use, defaults to the local time zone.
     - Parameter locale: The locale to use, defaults to the current locale
     - Returns The date formatter.
     */
    fileprivate static func formatter(format:String = DefaultFormat, timeZone: TimeZone = TimeZone.autoupdatingCurrent, locale: Locale = NSLocale.current) -> DateFormatter {
        let hashKey = "\(format.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
        var formatters = Date.sharedDateFormatters
        if let cachedDateFormatter = formatters[hashKey] {
            return cachedDateFormatter
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = timeZone as TimeZone!
            formatter.locale = locale as Locale!
            formatters[hashKey] = formatter
            return formatter
        }
    }
    
    /**
     Returns a cached formatter based on date style, time style and relative date. Formatters are cached in a singleton array using hashkeys generated by date style, time style, relative date, timeZone and locale.
     
     - Parameter dateStyle: The date style to use.
     - Parameter timeStyle: The time style to use.
     - Parameter doesRelativeDateFormatting: Enables relative date formatting.
     - Parameter timeZone: The time zone to use.
     - Parameter locale: The locale to use.
     - Returns The date formatter.
     */
    fileprivate static func formatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, doesRelativeDateFormatting: Bool, timeZone: TimeZone = TimeZone.autoupdatingCurrent, locale: Locale = Locale.current) -> DateFormatter {
        var formatters = Date.sharedDateFormatters
        let hashKey = "\(dateStyle.hashValue)\(timeStyle.hashValue)\(doesRelativeDateFormatting.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
        if let cachedDateFormatter = formatters[hashKey] {
            return cachedDateFormatter
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = dateStyle
            formatter.timeStyle = timeStyle
            formatter.doesRelativeDateFormatting = doesRelativeDateFormatting
            formatter.timeZone = timeZone as TimeZone!
            formatter.locale = locale as Locale!
            formatters[hashKey] = formatter
            return formatter
        }
    }
    
}

