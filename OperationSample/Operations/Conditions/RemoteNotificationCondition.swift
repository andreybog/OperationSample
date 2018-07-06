//
//  RemoteNotificationCondition.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/7/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import UIKit

private let RemoteNotificationQueue = BaseOperationQueue()
private let RemoteNotificationName = "RemoteNotificationPermissionNotification"

private enum RemoteRegistrationResult {
    case token(Data)
    case error(NSError)
}

/// A condition for verifying that the app has the ability to receive push notifications.
struct RemoteNotificationCondition: OperationCondition {
    static let name = "RemoteNotification"
    static let isMutuallyExclusive = false
    
    static func didReceiveNotificationToken(_ token: Data) {
        
    }
}
