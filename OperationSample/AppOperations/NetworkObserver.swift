//
//  NetworkObserver.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/21/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import UIKit

/**
 An `OperationObserver` that will cause the network activity indicator to appear
 as long as the `Operation` to which it is attached is executing.
 */
struct NetworkObserver: OperationObserver {
    init() { }
    
    func operationDidStart(_ operation: BaseOperation) {
        DispatchQueue.main.async {
            NetworkIndicatorController.shared.networkActivityDidStart()
        }
    }
    
    func operation(_ operation: BaseOperation, didProduceOperation newOperation: Operation) {
    }
    
    func operationDidFinish(_ operation: BaseOperation, errors: [NSError]) {
        DispatchQueue.main.async {
            NetworkIndicatorController.shared.networkActivityDidEnd()
        }
    }
}


/// A singleton to manage a visual "reference count" on the network activity indicator.
private class NetworkIndicatorController {
    static let shared = NetworkIndicatorController()
    
    private var activityCount = 0
    private var visibilityTimer: Timer?
    
    func networkActivityDidStart() {
        assert(Thread.isMainThread, "Alerting network activity indicator state can only be done on the main thread.")
        
        activityCount += 1
        updateIndicatorVisibility()
    }
    
    func networkActivityDidEnd() {
        assert(Thread.isMainThread, "Alerting network activity indicator state can only be done on the main thread.")
        
        activityCount -= 1
        updateIndicatorVisibility()
    }
    
    private func updateIndicatorVisibility() {
        if activityCount > 0 {
            showIndicator()
        }
        else {
            /*
             To prevent the indicator from flickering on and off, we delay the
             hiding of the indicator by one second. This provides the chance
             to come in and invalidate the timer before it fires.
             */
            visibilityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                self.hideIndicator()
            }
        }
    }
    
    private func showIndicator() {
        visibilityTimer?.invalidate()
        visibilityTimer = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideIndicator() {
        visibilityTimer?.invalidate()
        visibilityTimer = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
