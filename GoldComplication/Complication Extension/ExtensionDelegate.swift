//
//  ExtensionDelegate.swift
//  Complication Extension
//
//  Created by Lloyd Luck on 9/6/16.
//  Copyright © 2016 Lloyd Luck. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, URLSessionDataDelegate, URLSessionDelegate {
    
    let priceURL = URL(string: "https://jcsgold.com/price-data.xml")!
    
    var backgroundURLSession: URLSession?
    var backgroundTask: WKApplicationRefreshBackgroundTask?

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        scheduleNextBackgroundRefresh()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                print("Background task handled!")
                self.backgroundTask = backgroundTask
                backgroundURLSession = updatePrices(completion: nil)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                print("URL task handled!")
                let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: urlSessionTask.sessionIdentifier)
                let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: SessionManager.sharedInstance, delegateQueue: nil)
                
                print("Rejoining session", backgroundSession)
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    private func scheduleNextBackgroundRefresh() {
        print("Scheduling next refresh!")
        let preferredDate = Date(timeIntervalSinceNow: (15))
        print("Preferred Date: \(Formatters.lastModFormatter.string(from: preferredDate))")
        let userInfo: [String: Any] = ["lastUpdated": Date(),
                        "reason": "Spot Price Update"]
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: preferredDate, userInfo: userInfo as NSSecureCoding, scheduledCompletion: { error in
            if let error = error {
                // Background refresh was not scheduled, so handle error appropriately
                print("Error Scheduling Background Refresh: \(error)")
            }
        })
    }
    
    func updatePrices(completion: SpotUpdateCompletion?) -> URLSession {
        print("Updating prices!")
        let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: "com.Lluckios.GoldComplication")
        backgroundConfigObject.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        backgroundConfigObject.sessionSendsLaunchEvents = true
        let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)
        let dataTask = backgroundSession.dataTask(with: priceURL)
        dataTask.resume()
        return backgroundSession
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("!!! DATA RECEIVED !!!")
        // Received XML
        SessionManager.sharedInstance.receivedXML(data, completion: { [weak self] (_, _) in
            self?.scheduleNextBackgroundRefresh()
            self?.backgroundURLSession?.invalidateAndCancel()
            self?.backgroundURLSession = nil
            self?.backgroundTask?.setTaskCompleted()
            self?.backgroundTask = nil
        })
    }
}
