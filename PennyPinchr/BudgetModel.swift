//
//  BudgetModel.swift
//  PennyPinchr
//
//  Created by Matt Maher on 12/12/16.
//  Copyright © 2016 MMMD. All rights reserved.
//

import Foundation
import CoreData

class BudgetModel {
    
    private var _budget: String!
    
    var budget: String {
        return _budget
    }
    
    init(curBudget: NSManagedObject) {
        if let currentBudget = curBudget.value(forKey: "currentBudget") {
            self._budget = "\(currentBudget)"
        }
    }
}
