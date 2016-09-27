//
//  Formatters.swift
//  DianaApp
//
//  Created by Lloyd Luck on 3/16/15.
//  Copyright (c) 2015 Lloyd Luck. All rights reserved.
//

import UIKit

class Formatters: NSObject {
    
    class var dollarFormatter: NumberFormatter {
        struct Formatter {
            static let instance : NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.currency
                formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
                formatter.generatesDecimalNumbers = true
                return formatter
                }()
        }
        return Formatter.instance
    }
   
    class var oztFormatter: NumberFormatter {
        struct Formatter {
            static let instance : NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.decimal
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
                formatter.generatesDecimalNumbers = true
                formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
                return formatter
                }()
        }
        return Formatter.instance
    }
    
    class var integerFormatter: NumberFormatter {
        struct Formatter {
            static let instance : NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.decimal
                formatter.maximumFractionDigits = 0
                formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
                return formatter
            }()
        }
        return Formatter.instance
    }
    
    class var numberFormatter: NumberFormatter {
        struct Formatter {
            static let instance: NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.decimal
                formatter.generatesDecimalNumbers = true
                formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
                return formatter
            }()
        }
        return Formatter.instance
    }
    
    // MARK: - Date Formatters
    class var dateFormatter: DateFormatter {
        struct Formatter {
            static let instance: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.medium
                return formatter
            }()
        }
        return Formatter.instance
    }
    
    class var easternTimeZoneFormatter: DateFormatter {
        struct Formatter {
            static let instance: DateFormatter = {
                let formatter = DateFormatter()
                // Eastern Time Zone
                formatter.timeZone = TimeZone(secondsFromGMT: -18000)
                formatter.dateStyle = DateFormatter.Style.full
                formatter.timeStyle = DateFormatter.Style.full
                return formatter
            }()
        }
        return Formatter.instance
    }
    
    class var easternTimeZoneTimeFormatter: DateFormatter {
        struct Formatter {
            static let instance: DateFormatter = {
                let formatter = DateFormatter()
                // Eastern Time Zone
                formatter.timeZone = TimeZone(secondsFromGMT: -18000)
                formatter.dateFormat = "hh:mm:ss"
                return formatter
            }()
        }
        return Formatter.instance
    }
    
    // MARK: - Parsing XML Data
    
    class var lastModFormatter: DateFormatter {
        struct Formatter {
            static let instance: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"
                return formatter
            }()
        }
        return Formatter.instance
    }
    
}
