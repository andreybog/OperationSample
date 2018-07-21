//
//  BackgroundObserver.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/21/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import UIKit

/**
 `BackgroundObserver` is an `OperationObserver` that will automatically begin
 and end a background task if the application transitions to the background.
 This would be useful if you had a vital `Operation` whose execution *must* complete,
 regardless of the activation state of the app. Some kinds network connections
 may fall in to this category, for example.
 */
class BackgroundObserver: NSObject, OperationObserver {
    private var identifier = UIBackgroundTaskInvalid
    private var isInBackground = false
    
    override init() {
        super.init()
        
        // We need to know when the application moves to/from the background.
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: .UIApplicationDidBecomeActive, object: nil)
        
        isInBackground = UIApplication.shared.applicationState == .background
        
        // If we're in the background already, immediately begin the background task.
        if isInBackground {
            startBackgroundTask()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        if !isInBackground {
            isInBackground = true
            startBackgroundTask()
        }
    }
    
    @objc func didEnterForeground(_ notification: Notification) {
        if isInBackground {
            isInBackground = false
            endBackgroundTask()
        }
    }
    
    private func startBackgroundTask() {
        if identifier == UIBackgroundTaskInvalid {
            identifier = UIApplication.shared.beginBackgroundTask(withName: "BackgroundObserver", expirationHandler: {
                self.endBackgroundTask()
            })
        }
    }
    
    private func endBackgroundTask() {
        if identifier != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(identifier)
            identifier = UIBackgroundTaskInvalid
        }
    }
    
    //MARK: -
    //MARK: Operation Observer
    
    func operationDidStart(_ operation: BaseOperation) { }
    
    func operation(_ operation: BaseOperation, didProduceOperation newOperation: Operation) { }
    
    func operationDidFinish(_ operation: BaseOperation, errors: [NSError]) {
        endBackgroundTask()
    }
}
