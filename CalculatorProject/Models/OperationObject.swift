//
//  OperationObject.swift
//  CalculatorProject
//
//  Created by Charlie Sarano on 11/18/19.
//  Copyright © 2019 Sarano. All rights reserved.
//

struct OperationObject {
    
    var operation = ""
    
    var timestamp: Double = 0.0
    
    init(operation: String, timestamp: Double) {
        self.operation = operation
        self.timestamp = timestamp
    }
}


extension OperationObject: Comparable {
    static func < (lhs: OperationObject, rhs: OperationObject) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }
}

