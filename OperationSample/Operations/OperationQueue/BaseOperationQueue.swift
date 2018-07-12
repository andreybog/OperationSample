//
//  BaseOperationQueue.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/7/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

/**
 The delegate of an `OperationQueue` can respond to `Operation` lifecycle
 events by implementing these methods.
 
 In general, implementing `OperationQueueDelegate` is not necessary; you would
 want to use an `OperationObserver` instead. However, there are a couple of
 situations where using `OperationQueueDelegate` can lead to simpler code.
 For example, `GroupOperation` is the delegate of its own internal
 `OperationQueue` and uses it to manage dependencies.
 */
@objc protocol OperationQueueDelegate: NSObjectProtocol {
    @objc optional func operationQueue(_ operationQueue: BaseOperationQueue, willAddOperation operation: Operation)
    @objc optional func operationQueue(_ operationQueue: BaseOperationQueue, operationDidFinish operation: Operation, withErrors errors: [NSError])
}

/**
 `OperationQueue` is an `NSOperationQueue` subclass that implements a large
 number of "extra features" related to the `Operation` class:
 
 - Notifying a delegate of all operation completion
 - Extracting generated dependencies from operation conditions
 - Setting up dependencies to enforce mutual exclusivity
 */
class BaseOperationQueue: OperationQueue {
    weak var delegate: OperationQueueDelegate?
    
    override func addOperation(_ op: Operation) {
        weak var weak = self
    
        if let operation = op as? BaseOperation {

            let delegate = BlockObserver(
                startHandler: nil,
                produceHandler: {
                    weak?.addOperation($1)
                },
                finishHandler: {
                    if let q = weak {
                        q.delegate?.operationQueue?(q, operationDidFinish: $0, withErrors: $1)
                    }
                }
            )
            operation.addObserver(delegate)
            
            // Extract any dependencies needed by this operation.
            let dependencies = operation.conditions.compactMap {
                $0.dependencyForOperation(operation)
            }
            
            for dependency in dependencies {
                operation.addDependency(dependency)
                
                self.addOperation(dependency)
            }
            
            /*
             With condition dependencies added, we can now see if this needs
             dependencies to enforce mutual exclusivity.
             */
            let concurrencyCategories: [String] = operation.conditions.compactMap { condition in
                if !type(of: condition).isMutuallyExclusive { return nil }
                
                return "\(type(of: condition))"
            }
            
            if !concurrencyCategories.isEmpty {
                // Set up the mutual exclusivity dependencies.
                let exclusivityController = ExclusivityController.shared
                
                exclusivityController.addOperation(operation, categories: concurrencyCategories)
                
                operation.addObserver(BlockObserver(finishHandler: { operation, _ in
                    exclusivityController.removeOperation(operation, categories: concurrencyCategories)
                }))
            }
            
            /*
             Indicate to the operation that we've finished our extra work on it
             and it's now it a state where it can proceed with evaluating conditions,
             if appropriate.
             */
            operation.willEnqueue()
        }
        else {
            op.addCompletionBlock({ [weak op] in
                guard let queue = weak, let operation = op else { return }
                queue.delegate?.operationQueue?(queue, operationDidFinish: operation, withErrors: [])
            })
        }
        
        delegate?.operationQueue?(self, willAddOperation: op)
        super.addOperation(op)
    }
    
    override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        for op in ops {
            addOperation(op)
        }
        
        if wait {
            for op in operations {
                op.waitUntilFinished()
            }
        }
    }
}
