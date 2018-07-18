//
//  UserNotificationCondition.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/18/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import UIKit

/**
 A condition for verifying that we can present alerts to the user via
 `UILocalNotification` and/or remote notifications.
 */

struct UserNotificationCondition {
    enum Behavior {
        // Merge the new `UIUserNotificationSettings` with the `currentUserNotificationSettings`.
        case merge
        
        /// Replace the `currentUserNotificationSettings` with the new `UIUserNotificationSettings`.
        case replace
    }
}

/**
 A private `Operation` subclass to register a `UIUserNotificationSettings`
 object with a `UIApplication`, prompting the user for permission if necessary.
 */
private class UserNotificationPersmissionOperation: BaseOperation {
    let settings: UIUserNotificationSettings
    let application: UIApplication
    let behavior: UserNotificationCondition.Behavior
    
    init(settings: UIUserNotificationSettings, application: UIApplication, behavior: UserNotificationCondition.Behavior) {
        self.settings = settings
        self.application = application
        self.behavior = behavior
        
        super.init()
        
        addCondition(AlertPresentation())
    }
    
    override func execute() {
        DispatchQueue.main.async {
            let current = self.application.currentUserNotificationSettings
            
            let settingsToRegister: UIUserNotificationSettings
            
            switch (current, self.behavior) {
            case let (currentSettigns?, .merge):
                settingsToRegister = currentSettigns.settingsByMerging(self.settings)
            
            default:
                settingsToRegister = self.settings
            }
            
            self.application.registerUserNotificationSettings(settingsToRegister)
        }
    }
}
