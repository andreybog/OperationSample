//
//  Operation+Extensions.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/8/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

extension Operation {
    func addCompletionBlock(_ block: @escaping () -> Void) {
        if let existing = completionBlock {
            completionBlock = {
                existing()
                block()
            }
        }
        else {
            completionBlock = block
        }
    }
    
    func addDependencies(_ dependencies: [Operation]) {
        for dependency in dependencies {
            addDependency(dependency)
        }
    }
}
