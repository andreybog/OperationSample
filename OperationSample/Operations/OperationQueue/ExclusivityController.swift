//
//  ExclusivityController.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/7/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

/**
 `ExclusivityController` is a singleton to keep track of all the in-flight
 `Operation` instances that have declared themselves as requiring mutual exclusivity.
 We use a singleton because mutual exclusivity must be enforced across the entire
 app, regardless of the `OperationQueue` on which an `Operation` was executed.
 */
class ExclusivityController {
    static let shared = ExclusivityController()
    
    private let serialQueue = DispatchQueue(label: "Operations.ExclusivityController")
    private var operations: [String: [BaseOperation]] = [:]
    
    private init() {
    }
    
    /// Registers an operation as being mutually exclusive
    func addOperation(_ operation: BaseOperation, categories: [String]) {
        serialQueue.sync {
            for category in categories {
                self.noqueue_addOperation(operation, category: category)
            }
        }
    }
    
    /// Unregisters an operation from being mutually exclusive.
    func removeOperation(_ operation: BaseOperation, categories: [String]) {
        serialQueue.async {
            for category in categories {
                self.noqueue_removeOperation(operation, category: category)
            }
        }
    }
    
    //MARK: -
    //MARK: Operation Management
    
    private func noqueue_addOperation(_ operation: BaseOperation, category: String) {
        var operationsWithThisCategory = operations[category, default: []]
        
        if let last = operationsWithThisCategory.last {
            operation.addDependency(last)
        }
        
        operationsWithThisCategory.append(operation)
        
        operations[category] = operationsWithThisCategory
    }
    
    private func noqueue_removeOperation(_ operation: BaseOperation, category: String) {
        let matchingOperations = operations[category]
        
        if var operationsWithThisCategory = matchingOperations,
            let index = operationsWithThisCategory.index(of: operation) {
            
            operationsWithThisCategory.remove(at: index)
            operations[category] = operationsWithThisCategory
        }
    }
}
