//
//  PassbookCondition.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/17/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import PassKit

/// A condition for verifying that Passbook exists and is accessible.
struct PassbookCondition: OperationCondition {
    static let name = "Passbook"
    static let isMutuallyExclusive = false
    
    init() {
    }
    
    func dependencyForOperation(_ operation: BaseOperation) -> Operation? {
        /*
         There's nothing you can do to make Passbook available if it's not
         on your device.
         */
        
        return nil
    }
    
    func evaluateForOperation(_ operation: BaseOperation, completion: @escaping (OperationConditionResult) -> Void) {
        if PKPassLibrary.isPassLibraryAvailable() {
            completion(.satisfied)
        }
        else {
            let error = NSError(code: .conditionFailed, userInfo: [
                OperationConditionKey: type(of: self).name
            ])
            
            completion(.failed(error))
        }
    }
}
