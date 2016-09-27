//
//  NSDecimalNumber+Operator.swift
//  BullionStacker
//
//  Created by Lloyd Luck on 3/21/15.
//  Copyright (c) 2015 Lloyd Luck. All rights reserved.
//

import UIKit
    
    func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
        return lhs.compare(rhs) == ComparisonResult.orderedSame
    }
    
    func <=(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
        return !(lhs > rhs) || lhs == rhs
    }
    
    func >=(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    
    func >(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
        return lhs.compare(rhs) == ComparisonResult.orderedDescending
    }
    
    func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
        return !(lhs > rhs)
    }
    
    func +(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
        return lhs.adding(rhs)
    }
    
    func -(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
     return lhs.subtracting(rhs)
    }
    
    func *(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
        return lhs.multiplying(by: rhs)
    }
    
    func /(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
        return lhs.dividing(by: rhs)
    }
    
    func +=(lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
        lhs = lhs.adding(rhs)
    }
    
    func -=(lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
        lhs = lhs.subtracting(rhs)
    }
    
    func *=(lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
        lhs = lhs.multiplying(by: rhs)
    }
    
    func /=(lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
        lhs = lhs.dividing(by: rhs)
    }
    
    prefix func ++(lhs: inout NSDecimalNumber) -> NSDecimalNumber {
        return lhs.adding(NSDecimalNumber.one)
    }
    
    postfix func ++(lhs: inout NSDecimalNumber) -> NSDecimalNumber {
        let copy : NSDecimalNumber = lhs.copy() as! NSDecimalNumber
        lhs = lhs.adding(NSDecimalNumber.one)
        return copy
    }
    
    prefix func --(lhs: inout NSDecimalNumber) -> NSDecimalNumber {
        return lhs.subtracting(NSDecimalNumber.one)
    }
    
    postfix func --(lhs: inout NSDecimalNumber) -> NSDecimalNumber {
        let copy : NSDecimalNumber = lhs.copy() as! NSDecimalNumber
        lhs = lhs.subtracting(NSDecimalNumber.one)
        return copy
    }
    
    prefix func -(lhs: NSDecimalNumber) -> NSDecimalNumber {
        let minusOne: NSDecimalNumber = NSDecimalNumber(string: "-1")
        return lhs.multiplying(by: minusOne)
    }
    
    prefix func +(lhs: NSDecimalNumber) -> NSDecimalNumber {
        return lhs
    }
