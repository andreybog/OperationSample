//
//  NSLocking+Extensions.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/3/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

extension NSLocking {
    func withCriticalScope<T>(block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
