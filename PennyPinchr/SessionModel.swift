//
//  SessionModel.swift
//  PennyPinchr
//
//  Created by Matt Maher on 12/11/16.
//  Copyright © 2016 MMMD. All rights reserved.
//

import Foundation
import CoreData

class SessionModel {
    
    private var _date: String!
    private var _total: String!
    private var _cash: String!
    private var _credit: String!
    private var _budget: String!
    
    var date: String {
        return _date
    }
    
    var total: String {
        return _total
    }
    
    var cash: String {
        return _cash
    }
    
    var credit: String {
        return _credit
    }
    
    var budget: String {
        return _budget
    }
    
    init(session: NSManagedObject) {
        
        if let indDate = session.value(forKey: "date") {
            self._date = "\(indDate)"
        }
        
        if let indBudget = session.value(forKey: "budget") {
            self._budget = "\(indBudget)"
        }
        
        if let indCredit = session.value(forKey: "credit") {
            self._credit = "\(indCredit)"
        }
        
        if let indTotal = session.value(forKey: "total") {
            self._total = "\(indTotal)"
        }
        
        if let indCash = session.value(forKey: "cash") {
            self._cash = "\(indCash)"
        }
    }
}
