//
//  MutuallyExclusive.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/8/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

/// A generic condition for describing kinds of operations that may not execute concurrently.
struct MutuallyExclusive<T>: OperationCondition {
    static var name: String {
        return "MutuallyExclusive<\(T.self)>"
    }
    
    static var isMutuallyExclusive: Bool {
        return true
    }
    
    init() {}
    
    func dependencyForOperation(_ operation: BaseOperation) -> Operation? {
        return nil
    }
    
    func evaluateForOperation(_ operation: BaseOperation, completion: @escaping (OperationConditionResult) -> Void) {
        completion(.satisfied)
    }
}

/**
 The purpose of this enum is to simply provide a non-constructible
 type to be used with `MutuallyExclusive<T>`.
 */

enum Alert {}

typealias AlertPresentation = MutuallyExclusive<Alert>
