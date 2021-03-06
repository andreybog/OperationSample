//
//  LocationOperation.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/12/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation
import CoreLocation

/**
 `LocationOperation` is an `Operation` subclass to do a "one-shot" request to
 get the user's current location, with a desired accuracy. This operation will
 prompt for `WhenInUse` location authorization, if the app does not already
 have it.
 */
class LocationOperation: BaseOperation, CLLocationManagerDelegate {
    //MARK: -
    //MARK: Properties
    
    private let accuracy: CLLocationAccuracy
    private var manager: CLLocationManager?
    private let handler: (CLLocation) -> Void
    
    //MARK: -
    //MARK: Initialization
    
    init(accuracy: CLLocationAccuracy, locationHandler: @escaping (CLLocation) -> Void) {
        self.accuracy = accuracy
        self.handler = locationHandler
        super.init()
        addCondition(LocationCondition(usage: .whenInUse))
        addCondition(MutuallyExclusive<CLLocationManager>())
    }
    
    override func execute() {
        DispatchQueue.main.async {
            /*
             `CLLocationManager` needs to be created on a thread with an active
             run loop, so for simplicity we do this on the main queue.
             */
            let manager = CLLocationManager()
            manager.desiredAccuracy = self.accuracy
            manager.delegate = self
            manager.startUpdatingLocation()
            
            self.manager = manager
        }
    }
    
    override func cancel() {
        DispatchQueue.main.async {
            self.stopLocationUpdates()
            super.cancel()
        }
    }
    
    private func stopLocationUpdates() {
        manager?.stopUpdatingLocation()
        manager = nil
    }
    
    //MARK: -
    //MARK: CLLocationDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy <= accuracy else { return }
        
        stopLocationUpdates()
        handler(location)
        finish()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopLocationUpdates()
        finishWithError(error as NSError)
    }
}
