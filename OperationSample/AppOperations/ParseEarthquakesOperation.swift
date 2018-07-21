//
//  ParseEarthquakesOperation.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/21/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation
import CoreData

/// A struct to represent a parsed earthquake.
private struct ParsedEarthquake {
    let date: Date
    let identifier, name, link: String
    let depth, latitude, longitude, magnitude: Double
    
    init?(feature: [String: Any]) {
        guard let earthquakeID = feature["id"] as? String,
            !earthquakeID.isEmpty
        else {
            return nil
        }
        
        identifier = earthquakeID
        
        let properties = feature["properties"] as? [String: Any] ?? [:]
        
        name = properties["place"] as? String ?? ""
        
        link = properties["url"] as? String ?? ""
        
        magnitude = properties["mag"] as? Double ?? 0.0
        
        if let offset = properties["time"] as? Double {
            date = Date(timeIntervalSince1970: offset / 1000)
        }
        else {
            date = Date.distantFuture
        }
        
        let geometry = feature["geometry"] as? [String: Any] ?? [:]
        
        if let coordinates = geometry["coordinates"] as? [Double], coordinates.count == 3 {
            longitude = coordinates[0]
            latitude = coordinates[1]
            
            // `depth` is in km, but we want to store it in meters.
            depth = coordinates[2] * 1000
        }
        else {
            depth = 0
            latitude = 0
            longitude = 0
        }
    }
}

/// An `Operation` to parse earthquakes out of a downloaded feed from the USGS.
class ParseEarthquakesOperation: BaseOperation {
    let cacheFile: URL
    let context: NSManagedObjectContext
    
    /**
     - parameter cacheFile: The file `NSURL` from which to load earthquake data.
     - parameter context: The `NSManagedObjectContext` that will be used as the
     basis for importing data. The operation will internally
     construct a new `NSManagedObjectContext` that points
     to the same `NSPersistentStoreCoordinator` as the
     passed-in context.
     */
    init(cacheFile: URL, context: NSManagedObjectContext) {
        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        /*
         Use the overwrite merge policy, because we want any updated objects
         to replace the ones in the store.
         */
        importContext.mergePolicy = NSOverwriteMergePolicy
        
        self.cacheFile = cacheFile
        self.context = importContext
        
        super.init()
        
        name = "Parse Earthquakes"
    }
    
    override func execute() {
        guard let stream = InputStream(url: cacheFile) else {
            finish()
            return
        }
        
        stream.open()
        
        defer {
            stream.close()
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: stream, options: []) as? [String: Any]
            
            if let features = json?["features"] as? [[String: Any]] {
                parse(features)
            }
            else {
                finish()
            }
        }
        catch let jsonError as NSError {
            finishWithError(jsonError)
        }
    }
    
    private func parse(_ features: [[String: Any]]) {
        let parsedEarthquakes = features.compactMap(ParsedEarthquake.init)
        
        context.perform {
            parsedEarthquakes.forEach(self.insert)
            
            let error = self.saveContext()
            self.finishWithError(error as NSError?)
        }
    }
    
    private func insert(_ parsed: ParsedEarthquake) {
        let earthquake = NSEntityDescription.insertNewObject(forEntityName: Earthquake.enetityName, into: context) as! Earthquake
        
        earthquake.identifier = parsed.identifier
        earthquake.timestamp = parsed.date
        earthquake.latitude = parsed.latitude
        earthquake.longitude = parsed.longitude
        earthquake.magnitude = parsed.magnitude
        earthquake.depth = parsed.depth
        earthquake.webLink = parsed.link
        earthquake.name = parsed.name
    }
    
    /**
     Save the context, if there are any changes.
     
     - returns: An `NSError` if there was an problem saving the `NSManagedObjectContext`,
     otherwise `nil`.
     
     - note: This method returns an `NSError?` because it will be immediately
     passed to the `finishWithError()` method, which accepts an `NSError?`.
     */
    private func saveContext() -> Error? {
        var error: Error?
        
        if context.hasChanges {
            do {
                try context.save()
            }
            catch let saveError {
                error = saveError
            }
        }
        
        return error
    }
}
