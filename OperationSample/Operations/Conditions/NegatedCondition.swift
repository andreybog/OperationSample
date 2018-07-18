//
//  NegatedCondition.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/17/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

/**
 A simple condition that negates the evaluation of another condition.
 This is useful (for example) if you want to only execute an operation if the
 network is NOT reachable.
 */
struct NegatedCondition<T: OperationCondition>: OperationCondition {
    static var name: String {
        return "Not<\(T.name)>"
    }
    
    static var negatedConditionKey: String {
        return "NegatedCondition"
    }
    
    static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    let condition: T
    
    init(condition: T) {
        self.condition = condition
    }
    
    func dependencyForOperation(_ operation: BaseOperation) -> Operation? {
        return condition.dependencyForOperation(operation)
    }
    
    func evaluateForOperation(_ operation: BaseOperation, completion: @escaping (OperationConditionResult) -> Void) {
        condition.evaluateForOperation(operation) { result in
            if result == .satisfied {
                // If the composed condition succeeded, then this one failed.
                let error = NSError(code: .conditionFailed, userInfo: [
                    OperationConditionKey: type(of: self).name,
                    type(of: self).negatedConditionKey: type(of: self.condition).name
                ])
                
                completion(.failed(error))
            }
            else {
                // If the composed condition failed, then this one succeeded.
                completion(.satisfied)
            }
        }
    }
}
