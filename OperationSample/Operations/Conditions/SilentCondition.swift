//
//  SilentCondition.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/17/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

/**
 A simple condition that causes another condition to not enqueue its dependency.
 This is useful (for example) when you want to verify that you have access to
 the user's location, but you do not want to prompt them for permission if you
 do not already have it.
 */
struct SilentCondition<T: OperationCondition>: OperationCondition {
    let condition: T
    
    static var name: String {
        return "Silent<\(T.name)>"
    }
    
    static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    init(condition: T) {
        self.condition = condition
    }
    
    func dependencyForOperation(_ operation: BaseOperation) -> Operation? {
        // Returning nil means we will never a dependency to be generated.
        return nil
    }
    
    func evaluateForOperation(_ operation: BaseOperation, completion: @escaping (OperationConditionResult) -> Void) {
        condition.evaluateForOperation(operation, completion: completion)
    }
}
