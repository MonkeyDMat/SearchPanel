//
//  Functions.swift
//  ITMRed
//
//  Created by Mathieu Lecoupeur on 30/06/2017.
//  Copyright © 2017 mathieu lecoupeur. All rights reserved.
//

import Foundation

internal func min<C: Comparable, R: Any>(valuesToCompare: [C], valuesToReturn: [R]) -> R? {
    
    guard valuesToCompare.count == valuesToReturn.count else {
        return nil
    }
    
    var minIndex = 0
    var minValue = valuesToCompare[0]
    
    for (index, value) in valuesToCompare.enumerated() where value < minValue {
        
        minValue = value
        minIndex = index
    }
    
    return valuesToReturn[minIndex]
}
