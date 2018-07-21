//
//  DownloadEarthquakesOperation.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/21/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

class DownloadEarthquakesOperation: GroupOperation {
    let cacheFile: URL
    
    init(cacheFile: URL) {
        self.cacheFile = cacheFile
        super.init(operations: [])
        name = "Download Earthquakes"
        
        /*
         Since this server is out of our control and does not offer a secure
         communication channel, we'll use the http version of the URL and have
         added "earthquake.usgs.gov" to the "NSExceptionDomains" value in the
         app's Info.plist file. When you communicate with your own servers,
         or when the services you use offer secure communication options, you
         should always prefer to use https.
         */
        let url = URL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson")!
        let task = URLSession.shared.downloadTask(with: url) { url, response, error in
            self.downloadFinished(url: url, response: response, error: error)
        }
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(host: url)
        taskOperation.addCondition(reachabilityCondition)
        
        let networkObserver = NetworkObserver()
        taskOperation.addObserver(networkObserver)
        
        addOperation(taskOperation)
    }
    
    func downloadFinished(url: URL?, response: URLResponse?, error: Error?) {
        if let localURL = url {
            do {
                /*
                 If we already have a file at this location, just delete it.
                 Also, swallow the error, because we don't really care about it.
                 */
                try FileManager.default.removeItem(at: cacheFile)
            }
            catch { }
            
            do {
                try FileManager.default.moveItem(at: localURL, to: cacheFile)
            }
            catch let error as NSError {
                aggregateError(error)
            }
        }
        else if let error = error as NSError? {
            aggregateError(error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
}
