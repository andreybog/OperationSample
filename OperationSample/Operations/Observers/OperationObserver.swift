//
//  OperationObserver.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/6/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

protocol OperationObserver {
    
    /// Invoked immediately prior to the `Operation`'s `execute()` method.
    func operationDidStart(_ operation: BaseOperation)
    
    /// Invoked when `Operation.produceOperation(_:)` is executed.
    func operation(_ operation: BaseOperation, didProduceOperation newOperation: Operation)
    
    /**
     Invoked as an `Operation` finishes, along with any errors produced during
     execution (or readiness evaluation).
     */
    func operationDidFinish(_ operation: BaseOperation, errors: [NSError])
}
