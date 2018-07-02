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
    
    private var _internalErrors: [NSError] = []
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
