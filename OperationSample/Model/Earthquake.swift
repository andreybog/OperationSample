//
//  Earthquake.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/7/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Earthquake: NSManagedObject {
    //MARK: -
    //MARK: Static properties
    
    static let enetityName = "Earthquake"
    
    //MARK: -
    //MARK: Formatters
    
    static let timestampFormatter: DateFormatter = {
        let timestampFormatter = DateFormatter()
        
        timestampFormatter.dateStyle = .medium
        timestampFormatter.timeStyle = .medium
        
        return timestampFormatter
    }()
    
    static let magnitudeFormatter: NumberFormatter = {
        let magnitudeFormatter = NumberFormatter()
        
        magnitudeFormatter.numberStyle = .decimal
        magnitudeFormatter.maximumFractionDigits = 1
        magnitudeFormatter.minimumFractionDigits = 1
        
        return magnitudeFormatter
    }()
    
    static let depthFormatter: LengthFormatter = {
        let depthFormatter = LengthFormatter()
        
        depthFormatter.isForPersonHeightUse = false
        
        return depthFormatter
    }()
    
    static let distanceFormatter: LengthFormatter = {
        let distanceFormatter = LengthFormatter()
        
        distanceFormatter.isForPersonHeightUse = false
        distanceFormatter.numberFormatter.maximumFractionDigits = 2
        
        return distanceFormatter
    }()
    
    //MARK: -
    //MARK: Properties
    
    @NSManaged var identifier: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var name: String
    @NSManaged var magnitude: Double
    @NSManaged var timestamp: Date
    @NSManaged var depth: Double
    @NSManaged var webLink: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        return CLLocation(coordinate: coordinate, altitude: -depth, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timestamp)
    }
    
}
