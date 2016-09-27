//
//  Collection+Safe.swift
//  GoldComplication
//
//  Created by Lloyd Luck on 9/27/16.
//  Copyright © 2016 Lloyd Luck. All rights reserved.
//

import UIKit

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
