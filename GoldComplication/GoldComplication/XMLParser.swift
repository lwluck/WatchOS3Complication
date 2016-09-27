//
//  XMLParser.swift
//  Bullion Stacker
//
//  Created by Lloyd Luck on 3/13/15.
//  Copyright (c) 2015 Lloyd Luck. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

enum MetalType: String {
    case Gold = "Gold"
    case Silver = "Silver"
}

typealias SpotParseCompletionBlock = (_ spotPrice: String, _ date: String, _ error: NSError?) -> ()

class LWLXMLParser: XMLParser, XMLParserDelegate {
    
    // MARK: Public Variables
    var currentSpotPrice: String = ""
    var currentMetal: String = ""
    var date: String = ""
    var error: Error?
    
    class var noUpdateError: Error {
        return NSError(domain: "com.Lluckios.GoldComplication", code: 10, userInfo: nil)
    }
    
    // MARK: Private Variables
    fileprivate var currentCharacterData: String = ""
    fileprivate var completionBlock: SpotParseCompletionBlock = {(_, _, _) in }
    fileprivate var data: Data
    fileprivate var shouldSave: Bool = true
    
    override init(data: Data) {
        self.data = data
        super.init(data: data)
    }
    
    func parseXML(_ completion: SpotParseCompletionBlock?) {
        if let checkedCompletion = completion {
            completionBlock = checkedCompletion
        }
        let parser = Foundation.XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: Parser Constants
    
    let kSpotPriceKey: String = "spot_price"
    let kMetalKey: String = "metal"
    let kBidKey: String = "bid"
    let kAskKey: String = "ask"
    let kChangeKey: String = "change"
    let kPercentKey: String = "change-percent"
    let kGoldKey: String = "gold"
    let kSilverKey: String = "silver"
    let kLastModKey: String = "lastmod"
    
    // MARK: NSXMLParser Delegate Methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentCharacterData = ""
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case kBidKey:
            currentSpotPrice = currentCharacterData
        case kMetalKey:
            currentMetal = currentCharacterData
        case kLastModKey:
            let userDefaults = UserDefaults.standard
            var dates = userDefaults.value(forKey: "datesArray") as? [String] ?? []
            let spots = userDefaults.value(forKey: "spotsArray") as? [String] ?? []
            
            if let index = dates.index(of: currentCharacterData) {
                if let spot = spots[safe: index] {
                    shouldSave = false
                    currentSpotPrice = spot
                } else {
                    dates.remove(at: index)
                    userDefaults.set(dates, forKey: "datesArray")
                }
            } else {
                date = currentCharacterData
            }
        case kSpotPriceKey:
            if shouldSave {
                let userDefaults = UserDefaults.standard
                if currentMetal == kSilverKey && !date.isEmpty && !currentSpotPrice.isEmpty {
                    var dates = userDefaults.value(forKey: "datesArray") as? [String] ?? []
                    dates += [date]
                    userDefaults.set(dates, forKey: "datesArray")
                    
                    var spots = userDefaults.value(forKey: "spotsArray") as? [String] ?? []
                    spots += [currentSpotPrice]
                    userDefaults.set(spots, forKey: "spotsArray")
                }
            }
        default:
            // This means we encountered an unused value, no need to do anything
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentCharacterData += string
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        error = parseError
        print("A Parse error occurred")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if shouldSave {
            UserDefaults.standard.synchronize()
        }
        if error == nil && shouldSave == false {
            error = LWLXMLParser.noUpdateError
        }
        completionBlock(currentSpotPrice, date, error as NSError?)
    }
}
