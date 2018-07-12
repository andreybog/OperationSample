//
//  URLSessionTaskOperation.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/12/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

/*
 Abstract:
 Shows how to lift operation-like objects in to the NSOperation world.
 */

import Foundation

private var URLSessionTaskOperationKVOContext = 0

/**
 `URLSessionTaskOperation` is an `Operation` that lifts an `NSURLSessionTask`
 into an operation.
 
 Note that this operation does not participate in any of the delegate callbacks \
 of an `NSURLSession`, but instead uses Key-Value-Observing to know when the
 task has been completed. It also does not get notified about any errors that
 occurred during execution of the task.
 
 An example usage of `URLSessionTaskOperation` can be seen in the `DownloadEarthquakesOperation`.
 */
class URLSessionTaskOperation: BaseOperation {
    let task: URLSessionTask
    
    init(task: URLSessionTask) {
        assert(task.state == .suspended, "Tasks must be suspended.")
        self.task = task
        super.init()
    }
    
    override func execute() {
        assert(task.state == .suspended, "Task was resumed by something other than \(self).")
        
        task.addObserver(self, forKeyPath: "state", options: [], context: &URLSessionTaskOperationKVOContext)
        
        task.resume()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &URLSessionTaskOperationKVOContext else { return }
        
        if (object as AnyObject) === task && keyPath == "state" && task.state == .completed {
            task.removeObserver(self, forKeyPath: "state")
            finish()
        }
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
}
