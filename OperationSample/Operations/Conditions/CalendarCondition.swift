//
//  CalendarCondition.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/18/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import EventKit

/// A condition for verifying access to the user's calendar.
struct CalendarCondition: OperationCondition {
    static let name = "Calendar"
    static let entityTypeKey = "EKEntityType"
    static let isMutuallyExclusive = false
    
    let entityType: EKEntityType
    
    init(entityType: EKEntityType) {
        self.entityType = entityType
    }
    
    func dependencyForOperation(_ operation: BaseOperation) -> Operation? {
        return CalendarPermissionOperation(entityType: entityType)
    }
    
    func evaluateForOperation(_ operation: BaseOperation, completion: @escaping (OperationConditionResult) -> Void) {
        let status = EKEventStore.authorizationStatus(for: entityType)
        
        switch status {
        case .authorized:
            completion(.satisfied)
        default:
            // We are not authorized to access entities of this type.
            let error = NSError(code: .conditionFailed, userInfo: [
                OperationConditionKey: type(of: self).name,
                type(of: self).entityTypeKey: entityType.rawValue
            ])
            
            completion(.failed(error))
        }
    }
}

/**
 `EKEventStore` takes a while to initialize, so we should create
 one and then keep it around for future use, instead of creating
 a new one every time a `CalendarPermissionOperation` runs.
 */
private let SharedEventsStore = EKEventStore()

/**
 A private `Operation` that will request access to the user's Calendar/Reminders,
 if it has not already been granted.
 */
private class CalendarPermissionOperation: BaseOperation {
    let entityType: EKEntityType
    
    init(entityType: EKEntityType) {
        self.entityType = entityType
        super.init()
        addCondition(AlertPresentation())
    }
    
    override func execute() {
        let status = EKEventStore.authorizationStatus(for: entityType)
        
        switch status {
        case .notDetermined:
            DispatchQueue.main.async {
                SharedEventsStore.requestAccess(to: self.entityType) { granted, error in
                    self.finish()
                }
            }
            
        default:
            finish()
        }
    }
}
