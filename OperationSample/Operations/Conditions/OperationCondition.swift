//
//  OperationCondition.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/3/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

let OperationConditionKey = "OperationCondition"

/**
 A protocol for defining conditions that must be satisfied in order for an
 operation to begin execution.
 */

protocol OperationCondition {
    /**
     The name of the condition. This is used in userInfo dictionaries of `.ConditionFailed`
     errors as the value of the `OperationConditionKey` key.
     */
    static var name: String { get }
    
    /**
     Specifies whether multiple instances of the conditionalized operation may
     be executing simultaneously.
     */
    static var isMutuallyExclusive: Bool { get }
    
    /**
     Some conditions may have the ability to satisfy the condition if another
     operation is executed first. Use this method to return an operation that
     (for example) asks for permission to perform the operation
     
     - parameter operation: The `Operation` to which the Condition has been added.
     - returns: An `NSOperation`, if a dependency should be automatically added. Otherwise, `nil`.
     - note: Only a single operation may be returned as a dependency. If you
     find that you need to return multiple operations, then you should be
     expressing that as multiple conditions. Alternatively, you could return
     a single `GroupOperation` that executes multiple operations internally.
     */
    func dependencyForOperation(_ operation: BaseOperation) -> Operation?
    
    /// Evaluate the condition, to see if it has been satisfied or not.
    func evaluateForOperation(_ operation: BaseOperation, completion: @escaping (OperationConditionResult) -> Void)
}

enum OperationConditionResult: Equatable {
    case satisfied
    case failed(NSError)
    
    var error: NSError? {
        if case let .failed(error) = self {
            return error
        }
        
        return nil
    }
}

//MARK: -
//MARK: Evaluate Conditions

struct OperationConditionEvaluator {
    static func evaluate(_ conditions: [OperationCondition], operation: BaseOperation, completion: @escaping ([NSError]) -> Void) {
        let conditionGroup = DispatchGroup()
        
        var results = [OperationConditionResult?](repeating: nil, count: conditions.count)
        
        for (index, condition) in conditions.enumerated() {
            conditionGroup.enter()
            condition.evaluateForOperation(operation) { result in
                results[index] = result
                conditionGroup.leave()
            }
        }
        
        conditionGroup.notify(queue: .global(qos: .default)) {
            var failures = results.compactMap { $0?.error }
            
            if operation.isCancelled {
                failures.append(NSError(code: .conditionFailed))
            }
            
            completion(failures)
        }
    }
}
