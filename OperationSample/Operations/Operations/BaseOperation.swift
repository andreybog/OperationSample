//
//  BaseOperation.swift
//  OperationSample
//
//  Created by Andrey Bogushev on 7/3/18.
//  Copyright © 2018 Andrey Bogushev. All rights reserved.
//

import Foundation

class BaseOperation: Operation {
    class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return ["state"]
    }
    
    //MARK: -
    //MARK: State Management
    
    /**
     Indicates that the Operation can now begin to evaluate readiness conditions,
     if appropriate.
     */
    func willEnqueue() {
        state = .pending
    }
    
    private var _state = State.initialized
    private let stateLock = NSLock()
    
    private var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        
        set (newState) {
            willChangeValue(forKey: "state")
            
            stateLock.withCriticalScope {
                guard _state != .finished else {
                    return
                }
                
                assert(_state.canTransitionToState(newState), "Performing invalid state transition.")
                _state = newState
            }
            
            didChangeValue(forKey: "state")
        }
    }
    
    override var isReady: Bool {
        switch state {
        case .initialized:
            return isCancelled
            
        case .pending:
            guard !isCancelled else {
                return true
            }
            
            if super.isReady {
                evaluateConditions()
            }
            
            return false
            
        case .ready:
            return super.isReady || isCancelled
            
        default:
            return false
        }
    }
    
    var userInitiated: Bool {
        get {
            return qualityOfService == .userInitiated
        }
        
        set {
            assert(state < .executing, "Cannot modify userInitiated after execution has begun.")
            qualityOfService = newValue ? .userInitiated : .default
        }
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    private func evaluateConditions() {
        assert(state == .pending && !isCancelled, "evaluateConditions() was called out-of-order")
        
        state = .evaluatingConditions
        
        OperationConditionEvaluator.evaluate(conditions, operation: self) { failures in
            self._internalErrors.append(contentsOf: failures)
            self.state = .ready
        }
    }
    
    //MARK: -
    //MARK: Observers and Conditions
    
    private(set) var conditions: [OperationCondition] = []
    
    func addCondition(_ condition: OperationCondition) {
        assert(state < .evaluatingConditions, "Cannot modify conditions after execution has begun.")
        
        conditions.append(condition)
    }
    
    private(set) var observers: [OperationObserver] = []
    
    func addObserver(_ observer: OperationObserver) {
        assert(state < .executing, "Cannot modify observers after execution has begun.")
        
        observers.append(observer)
    }
    
    override func addDependency(_ op: Operation) {
        assert(state < .executing, "Dependencies cannot be modified after execution has begun.")
        
        super.addDependency(op)
    }
    
    //MARK: -
    //MARK: Execution and Cancellation
    
    override final func start() {
        super.start()
        
        if isCancelled {
            finish()
        }
    }
    
    override final func main() {
        assert(state == .ready, "This operation must be performed on an operation queue.")
        
        if _internalErrors.isEmpty && !isCancelled {
            state = .executing
            
            for observer in observers {
                observer.operationDidStart(self)
            }
            
            execute()
        }
        else {
            finish()
        }
    }
    
    open func execute() {
        print("\(type(of: self)) must override `execute()`.")
        
        finish()
    }
    
    private var _internalErrors: [NSError] = []
    
    func cancelWithError(_ error: NSError? = nil) {
        if let error = error {
            _internalErrors.append(error)
        }
        
        cancel()
    }
    
    //MARK: -
    //MARK: Finishing
    
    /**
     A private property to ensure we only notify the observers once that the
     operation has finished.
     */
    private var hasFinishedAlready = false
    
    final func finish(_ errors: [NSError] = []) {
        if !hasFinishedAlready {
            hasFinishedAlready = true
            state = .finishing
            
            let combinedErrors = _internalErrors + errors
            finished(combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(self, errors: combinedErrors)
            }
            
            state = .finished
        }
    }
    
    /**
     Subclasses may override `finished(_:)` if they wish to react to the operation
     finishing with errors. For example, the `LoadModelOperation` implements
     this method to potentially inform the user about an error when trying to
     bring up the Core Data stack.
     */
    
    open func finished(_ errors: [NSError]) {
        // No op.
    }
    
    override final func waitUntilFinished() {
        fatalError("Waiting on operations is an anti-pattern. Remove this ONLY if you're absolutely sure there is No Other Way™.")
    }
}

//MARK: -
//MARK: State

private extension BaseOperation {
    enum State: Int, Comparable {
        case initialized
        case pending
        case evaluatingConditions
        case ready
        case executing
        case finishing
        case finished
        
        func canTransitionToState(_ target: State) -> Bool {
            switch (self, target) {
            case (.initialized, .pending),
                 (.pending, .evaluatingConditions),
                 (.evaluatingConditions, .ready),
                 (.ready, .executing),
                 (.ready, .finishing),
                 (.executing, .finishing),
                 (.finishing, .finished):
                return true
            default:
                return false
            }
        }
    }
}

private func < (lhs: BaseOperation.State, rhs: BaseOperation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}


private func == (lhs: BaseOperation.State, rhs: BaseOperation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
