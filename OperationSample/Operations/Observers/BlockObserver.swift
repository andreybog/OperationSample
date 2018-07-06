//
//  BlockObserver.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/7/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

/**
 The `BlockObserver` is a way to attach arbitrary blocks to significant events
 in an `Operation`'s lifecycle.
 */
struct BlockObserver: OperationObserver {
    //MARK: -
    //MARK: Properties
    
    private let startHandler: ((BaseOperation) -> Void)?
    private let produceHandler: ((BaseOperation, Operation) -> Void)?
    private let finishHandler: ((BaseOperation, [NSError]) -> Void)?
    
    init(startHandler: ((BaseOperation) -> Void)? = nil,
         produceHandler: ((BaseOperation, Operation) -> Void)? = nil,
         finishHandler: ((BaseOperation, [NSError]) -> Void)? = nil) {
        
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    //MARK: -
    //MARK: OperationObserver
    
    func operationDidStart(_ operation: BaseOperation) {
        startHandler?(operation)
    }
    
    func operation(_ operation: BaseOperation, didProduceOperation newOperation: Operation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(_ operation: BaseOperation, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}
