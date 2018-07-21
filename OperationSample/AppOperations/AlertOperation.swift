//
//  AlertOperation.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/21/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import UIKit

class AlertOperation: BaseOperation {
    //MARK: -
    //MARK: Properties
    
    private let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private let presentationContext: UIViewController?
    
    var title: String? {
        get { return alertController.title }
        set {
            alertController.title = newValue
            name = newValue
        }
    }
    
    var message: String? {
        get { return alertController.message }
        set { alertController.message = newValue }
    }
    
    //MARK: -
    //MARK: Initialization
    
    init(presentationContext: UIViewController? = nil) {
        self.presentationContext = presentationContext ?? UIApplication.shared.keyWindow?.rootViewController
        super.init()
        
        addCondition(AlertPresentation())
        
        /*
         This operation modifies the view controller hierarchy.
         Doing this while other such operations are executing can lead to
         inconsistencies in UIKit. So, let's make them mutally exclusive.
         */
        addCondition(MutuallyExclusive<UIViewController>())
    }
    
    func addAction(title: String, style: UIAlertActionStyle = .default, handler: @escaping (AlertOperation) -> Void = { _ in }) {
        let action = UIAlertAction(title: title, style: style) { [weak self] _ in
            if let strong = self {
                handler(strong)
            }
            
            self?.finish()
        }
        
        alertController.addAction(action)
    }
    
    override func execute() {
        guard let presentationContext = presentationContext else {
            finish()
            return
        }
        
        DispatchQueue.main.async {
            if self.alertController.actions.isEmpty {
                self.addAction(title: "OK")
            }
            
            presentationContext.present(self.alertController, animated: true, completion: nil)
        }
    }
}

