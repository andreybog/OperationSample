//
//  EathquakeTableCell.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/31/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import UIKit

class EathquakeTableViewCell: UITableViewCell {
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var magnitudeLabel: UILabel!
    @IBOutlet var magnitudeImage: UIImageView!
    
    func configure(_ earthquake: Earthquake) {
        timestampLabel.text = Earthquake.timestampFormatter.string(from: earthquake.timestamp)
        
        magnitudeLabel.text = Earthquake.magnitudeFormatter.string(from: NSNumber(value: earthquake.magnitude))
        
        locationLabel.text = earthquake.name
        
        let imageName: String
        
        switch earthquake.magnitude {
        case 0..<2: imageName = ""
        case 2..<3: imageName = "2.0"
        case 3..<4: imageName = "3.0"
        case 4..<5: imageName = "4.0"
        default: imageName = "5.0"
        }
        
        magnitudeImage.image = UIImage(named: imageName)
    }

}
