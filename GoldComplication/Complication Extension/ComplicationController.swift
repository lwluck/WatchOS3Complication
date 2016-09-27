//
//  ComplicationController.swift
//  Complication Extension
//
//  Created by Lloyd Luck on 9/6/16.
//  Copyright © 2016 Lloyd Luck. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let userDefaults = UserDefaults.standard
        let dates = userDefaults.value(forKey: "datesArray") as? [String] ?? []
        
        // Default to current time if we do not have any dates in array
        var date = Date()
        if let firstDateString = dates.first, let firstDate = Formatters.lastModFormatter.date(from: firstDateString) {
            // We have a previous date, so use it
            date = firstDate
        }
        handler(date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // We don't support forward time travel, so just use the current date
        // If we figure out forward time travel, we could be VERY wealthy!
        handler(Date())
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        print("Getting the timeline entry!!!")
        let silverSpotPrice = SessionManager.sharedInstance.fetchSpotFromCoreDataForMetal(.Silver)
        handler(timeLineEntry(forSpot: silverSpotPrice?.spot, date: silverSpotPrice?.date, andComplication: complication, isCurrent: true))
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        
        // Get the dates we have stored
        let dateStrings = UserDefaults.standard.value(forKey: "datesArray") as? [String] ?? []
        let dates: [Date] = dateStrings.map() {
            Formatters.lastModFormatter.date(from: $0)!
        }
        
        // Get the index of the last date that is before the given date
        let validDates = dates.filter() {
            $0.isEarlierThanDate(date)
        }
        guard !validDates.isEmpty else {
            // If we don't have any dates before the given date, then pass nil
            handler(nil)
            return
        }
        
        // Get the spots from UserDefaults
        let spots = UserDefaults.standard.value(forKey: "spotsArray") as? [String] ?? []
        
        let result: [CLKComplicationTimelineEntry] = validDates.enumerated().flatMap({
            let dateString = Formatters.lastModFormatter.string(from: $0.element)
            return self.timeLineEntry(forSpot: spots[$0.offset], date: dateString, andComplication: complication, isCurrent: false)
        })
        
        handler(result)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
    private func timeLineEntry(forSpot spot: String?, date: String?, andComplication complication: CLKComplication, isCurrent: Bool) -> CLKComplicationTimelineEntry? {
        // Call the handler with the current timeline entry
        switch complication.family {
        case .utilitarianLarge:
            guard let date = date, let spot = spot else { return nil }
            print("Silver Spot Price Fetched: \(spot)")
            let silverSpot = NSDecimalNumber(string: spot)
            let updateDate = Date()
            let updateTime = Formatters.easternTimeZoneTimeFormatter.string(from: updateDate)
            let textProvider = CLKSimpleTextProvider(text: "\(updateTime) \(silverSpot.dollarFormat())", shortText: "SLV \(silverSpot.dollarFormat())")
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = textProvider
            let lastModDate = isCurrent ? Date() : Formatters.lastModFormatter.date(from: date)!
            let entry = CLKComplicationTimelineEntry(date: lastModDate, complicationTemplate: template)
            return entry
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallSquare()
            let imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
            template.imageProvider = imageProvider
            return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            
        case .modularSmall:
            guard let date = date, let spot = spot else { return nil }
            print("Silver Spot Price Fetched: \(spot)")
            let silverSpot = NSDecimalNumber(string: spot)
            let template = CLKComplicationTemplateModularSmallStackText()
            let updateTime = Formatters.lastModFormatter.date(from: date)!
            let textProvider = CLKRelativeDateTextProvider(date: updateTime, style: .natural, units: [.minute])
            textProvider.tintColor = UIColor.darkSilverColor()
            template.line1TextProvider = textProvider
            
            template.line2TextProvider = CLKSimpleTextProvider(text: silverSpot.oztFormat())
            
            let complicationDate = isCurrent ? Date() : updateTime
            let entry = CLKComplicationTimelineEntry(date: complicationDate, complicationTemplate: template)
            return entry
            
        case .modularLarge:
            guard let date = date, let spot = spot else { return nil }
            print("Silver Spot Price Fetched: \(spot)")
            let silverSpot = NSDecimalNumber(string: spot)
            let template = CLKComplicationTemplateModularLargeStandardBody()
            let updateTime = Formatters.lastModFormatter.date(from: date)!
            
            template.headerTextProvider = CLKSimpleTextProvider(text: "GoldComplication", shortText: "Complication")
            
            template.body1TextProvider = CLKSimpleTextProvider(text: "Silver \(silverSpot.dollarFormat())", shortText: "SLV \(silverSpot.dollarFormat())")
            
            if isCurrent {
                template.body2TextProvider = CLKSimpleTextProvider(text: "Current: \(Formatters.easternTimeZoneTimeFormatter.string(from: Date()))")
            } else {
                template.body2TextProvider = CLKSimpleTextProvider(text: "Past: \(Formatters.easternTimeZoneTimeFormatter.string(from: updateTime))")
            }
            let complicationDate = isCurrent ? Date() : updateTime
            let entry = CLKComplicationTimelineEntry(date: complicationDate, complicationTemplate: template)
            return entry
            
        case .circularSmall:
            print("Unhandled Complication")
            return nil
        case .extraLarge:
            print("Unhandled Complication")
            return nil
        }
    }
    
}
