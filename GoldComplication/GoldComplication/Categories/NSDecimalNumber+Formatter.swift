//
//  NSDecimalNumber+Formatter.swift
//  BullionStacker
//
//  Created by Lloyd Luck on 4/12/15.
//  Copyright (c) 2015 Lloyd Luck. All rights reserved.
//

import UIKit

extension NSDecimalNumber {
    
    func dollarFormat() -> String {
        return Formatters.dollarFormatter.string(from: self) ?? "Loading"
    }
    
    func oztFormat() -> String {
        return Formatters.oztFormatter.string(from: self) ?? "Loading"
    }
    
    func integerFormat() -> String {
        return Formatters.integerFormatter.string(from: self) ?? "Loading"
    }
}
