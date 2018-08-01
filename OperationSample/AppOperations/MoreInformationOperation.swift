//
//  MoreInformationOperation.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/21/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation
import SafariServices

/// An `Operation` to display an `NSURL` in an app-modal `SFSafariViewController`.
class MoreInformationOperation: BaseOperation {
    let url: URL
    
    init(url: URL) {
        self.url = url
        
        super.init()
        
        addCondition(MutuallyExclusive<UIViewController>())
    }
    
    deinit {
        print("MoreInformationOperation deinit...")
    }
    
    override func execute() {
        DispatchQueue.main.async {
            self.showSafariViewController()
        }
    }
    
    private func showSafariViewController() {
        if let context = UIApplication.shared.keyWindow?.rootViewController {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            
            let safari = SFSafariViewController(url: url, configuration: config)
            safari.delegate = self
            context.present(safari, animated: true, completion: nil)
        }
        else {
            finish()
        }
    }
}

extension MoreInformationOperation: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        finish()
    }
}
