//
//  NoCancelledDependencies.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/17/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

/**
 A condition that specifies that every dependency must have succeeded.
 If any dependency was cancelled, the target operation will be cancelled as
 well.
 */
struct NoCancelledDependencies: OperationCondition {
    static let name = "NoCancelledDependencies"
    static let cancelledDependenciesKey = "CancelledDependencies"
    static let isMutuallyExclusive = false
    
    init() {
    }
    
    func dependencyForOperation(_ operation: BaseOperation) -> Operation? {
        return nil
    }
    
    func evaluateForOperation(_ operation: BaseOperation, completion: @escaping (OperationConditionResult) -> Void) {
        // Verify that all of the dependencies executed.
        let cancelled = operation.dependencies.filter { $0.isCancelled }
        
        if !cancelled.isEmpty {
            // At least one dependency was cancelled; the condition was not satisfied.
            let error = NSError(code: .conditionFailed, userInfo: [
                OperationConditionKey: type(of: self).name,
                type(of: self).cancelledDependenciesKey: cancelled
            ])
            
            completion(.failed(error))
        }
        else {
            completion(.satisfied)
        }
    }
}
