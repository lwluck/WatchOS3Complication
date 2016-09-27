//
//  SessionManager.swift
//  BullionStacker
//
//  Created by Lloyd Luck on 5/7/15.
//  Copyright (c) 2015 Lloyd Luck. All rights reserved.
//

import UIKit
import CoreData

typealias SpotUpdateCompletion = (_ silverSpot: (spot: String, date: String)?, _ error: NSError?) -> ()

protocol ComplicationUpdateDelegate {
    func updateComplication()
}

class SessionManager: NSObject, URLSessionDataDelegate, URLSessionDelegate {
    
    static let sharedInstance = SessionManager()
    
    private(set) var silverSpot: String?
    
    let priceURL = URL(string: "https://jcsgold.com/price-data.xml")!
    
    class var supportedMetals: [MetalType] { return [MetalType.Gold, MetalType.Silver] }
    class func updateSpotPrices(_ completion: SpotUpdateCompletion? = nil) -> URLSession {
        return SessionManager.sharedInstance.updatePrices(completion)
    }
    
    private func updatePrices(_ completion: SpotUpdateCompletion?) -> URLSession {
        print("Updating prices!")
        let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: "com.Lluckios.GoldComplication")
        backgroundConfigObject.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        backgroundConfigObject.sessionSendsLaunchEvents = true
        let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)
        let dataTask = backgroundSession.dataTask(with: priceURL)
        dataTask.resume()
        return backgroundSession
        /**
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            let sessionConfiguration = URLSessionConfiguration.default
            
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                guard let data = data , error == nil else {
                    print("Error getting data")
                    print("Response Status: \(response)")
                    print("Error: \(error)")
                    DispatchQueue.main.async(execute: {
                        completion?(nil, nil, error as NSError?)
                    })
                    return
                }
                self.receivedXML(data, completion: completion)
            })
            task.resume()
        }
        */
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("!!! DATA RECEIVED !!!")
        // Received XML
        self.receivedXML(data, completion: nil)
    }
    
    func fetchSpotFromCoreDataForMetal(_ metal: MetalType) -> (spot: String, date: String)? {
        let userDefaults = UserDefaults.standard
        
        guard let dates = userDefaults.value(forKey: "datesArray") as? [String],
            let spots = userDefaults.value(forKey: "spotsArray") as? [String],
            let spot = spots.last,
            let date = dates.last else
        {
            print("Error getting the spots")
            return nil
        }
        
        return (spot: spot, date: date)
    }
    
    func receivedXML(_ data: Data, completion: SpotUpdateCompletion?) {
        LWLXMLParser(data: data).parseXML({[weak self](spotPrice, date, error) in
            self?.silverSpot = spotPrice
            print("\(self?.silverSpot)")
//                guard error == nil else {
//                    print("Error: \(error)")
//                    dispatch_async(dispatch_get_main_queue(),{
//                        completion?(goldSpot: self?.goldSpot, silverSpot: self?.silverSpot, error: error)
//                    })
//                    return
//                }
            if let sessionManager = self as? ComplicationUpdateDelegate {
                print("Complication Delegate reached!")
                sessionManager.updateComplication()
            }
            DispatchQueue.main.async(execute: {
                completion?((spot: spotPrice, date: date), error)
            })
        })
    }
}
