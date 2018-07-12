//
//  DelayOperation.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/13/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

/*
Abstract:
This file shows how to make an operation that efficiently waits.
*/

import Foundation

/**
 `DelayOperation` is an `Operation` that will simply wait for a given time
 interval, or until a specific `NSDate`.
 
 It is important to note that this operation does **not** use the `sleep()`
 function, since that is inefficient and blocks the thread on which it is called.
 Instead, this operation uses `dispatch_after` to know when the appropriate amount
 of time has passed.
 
 If the interval is negative, or the `NSDate` is in the past, then this operation
 immediately finishes.
 */
class DelayOperation: BaseOperation {
    //MARK: -
    //MARK: Types
    
    private enum Delay {
        case interval(TimeInterval)
        case date(Date)
    }
    
    //MARK: -
    //MARK: Properties
    
    private let delay: Delay
    
    //MARK: -
    //MARK: Initialization
    
    init(interaval: TimeInterval) {
        delay = .interval(interaval)
        super.init()
    }
    
    init(until date: Date) {
        delay = .date(date)
        super.init()
    }
    
    override func execute() {
        let interval: TimeInterval
        
        // Figure out how long we should wait for.
        switch delay {
        case let .interval(thInterval):
            interval = thInterval
        case let .date(date):
            interval = date.timeIntervalSinceNow
        }
        
        guard interval > 0 else {
            finish()
            return
        }
        
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now()+interval) {
            // If we were cancelled, then finish() has already been called.
            if !self.isCancelled {
                self.finish()
            }
        }
    }
    
    override func cancel() {
        super.cancel()
        // Cancelling the operation means we don't want to wait anymore.
        finish()
    }
}
