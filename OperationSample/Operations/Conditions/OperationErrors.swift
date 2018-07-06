//
//  OperationErrors.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/3/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

let OperationErrorDomain = "OperationErrors"

enum OperationErrorCode: Int {
    case conditionFailed = 1
    case executionFailed = 2
}

extension NSError {
    convenience init(code: OperationErrorCode, userInfo: [String: Any]? = nil) {
        self.init(domain: OperationErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}

func ==(lhs: Int, rhs: OperationErrorCode) -> Bool {
    return lhs == rhs.rawValue
}

func ==(lhs: OperationErrorCode, rhs: Int) -> Bool {
    return lhs.rawValue == rhs
}
