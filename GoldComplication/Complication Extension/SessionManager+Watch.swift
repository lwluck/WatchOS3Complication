//
//  SessionManager.swift
//  BullionStacker
//
//  Created by Lloyd Luck on 5/7/15.
//  Copyright (c) 2015 Lloyd Luck. All rights reserved.
//

import UIKit
import CoreData
import ClockKit

extension SessionManager: ComplicationUpdateDelegate {
    
    func updateComplication() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        print("Reloading complications for: \(complicationServer.activeComplications)")
        for complication in (complicationServer.activeComplications ?? []) {
            print("extendingComplication!")
            complicationServer.extendTimeline(for: complication)
        }
    }

}
