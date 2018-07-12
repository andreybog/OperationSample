//
//  APBlockOperation.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/12/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

typealias OperationBlock = (@escaping () -> Void) -> Void


class APBlockOperation: BaseOperation {
    private let block: OperationBlock?
    
    /**
     The designated initializer.
     
     - parameter block: The closure to run when the operation executes. This
     closure will be run on an arbitrary queue. The parameter passed to the
     block **MUST** be invoked by your code, or else the `BlockOperation`
     will never finish executing. If this parameter is `nil`, the operation
     will immediately finish.
     */
    init(block: OperationBlock? = nil) {
        self.block = block
        super.init()
    }
    
    /**
     A convenience initializer to execute a block on the main queue.
     
     - parameter mainQueueBlock: The block to execute on the main queue. Note
     that this block does not have a "continuation" block to execute (unlike
     the designated initializer). The operation will be automatically ended
     after the `mainQueueBlock` is executed.
     */
    convenience init(mainQueueBlock: @escaping () -> Void) {
        self.init(block: { continuation in
            DispatchQueue.main.async {
                mainQueueBlock()
                continuation()
            }
        })
    }
    
    override func execute() {
        guard let block = self.block else {
            finish()
            return
        }
        
        block {
            self.finish()
        }
    }
}
