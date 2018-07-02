//
//  OperationCondition.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/3/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

let OperationConditionKey = "OperationCondition"

protocol OperationCondition {
    static var name: String { get }
    static var isMutuallyExclusive: Bool { get }
    
    func dependencyForOperation(_ operation: BaseOperation) -> Operation?
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
