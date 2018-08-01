//
//  SplitViewController.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 8/1/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        preferredDisplayMode = .allVisible
        
        delegate = self
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let navigation = secondaryViewController as? UINavigationController else { return false }
        guard let detail = navigation.viewControllers.first as? EarthquakeTableViewController else { return false }
        
        return detail.earthquake == nil
    }
}
