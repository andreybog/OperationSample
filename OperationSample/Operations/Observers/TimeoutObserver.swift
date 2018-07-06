//
//  TimeoutObserver.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/7/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

/**
 `TimeoutObserver` is a way to make an `Operation` automatically time out and
 cancel after a specified time interval.
 */
struct TimeoutObserver: OperationObserver {
    //MARK: -
    //MARK: Properties
    
    static let timeoutKey = "Timeout"
    
    private let timeout: TimeInterval
    
    //MARK: -
    //MARK: Initialization
    
    init(timeout: TimeInterval) {
        self.timeout = timeout
    }
    
    //MARK: -
    //MARK: OperationObserver
    
    func operationDidStart(_ operation: BaseOperation) {
        // When the operation starts, queue up a block to cause it to time out.
        
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now()+timeout) {
            /*
             Cancel the operation if it hasn't finished and hasn't already
             been cancelled.
             */
            if !operation.isFinished && !operation.isCancelled {
                let error = NSError(code: .executionFailed, userInfo: [
                    type(of: self).timeoutKey: self.timeout
                ])
                
                operation.cancelWithError(error)
            }
        }
    }
    
    func operation(_ operation: BaseOperation, didProduceOperation newOperation: Operation) {
        // No op.
    }
    
    func operationDidFinish(_ operation: BaseOperation, errors: [NSError]) {
        // No op.
    }
    
}
