//
//  DataService.swift
//  PennyPinchr
//
//  Created by Matt Maher on 12/11/16.
//  Copyright © 2016 MMMD. All rights reserved.
//

import UIKit
import CoreData

class DataService {
    static let ds = DataService()
    
    let defaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var sessions = [NSManagedObject]()
    
    func toMoney(rawMoney: Double) -> String {
        return "$\(String(format: "%.2f", rawMoney))"
    }
    
    func taxArray() -> [Int] {
        var taxes = [Int]()
        
        for tax in 0...9 {
            taxes.append(tax)
        }
        
        return taxes
    }
    
    func priceWithTax(rawPrice: Double, tax: Double) -> Double {
        var price = 0.0
        
        price = rawPrice * ((tax / 100) + 1)
        
        return price
    }
    
    func dateToday() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        
        return formatter.string(from: today)
    }
    
    func saveSessionLocally(budget: Double, credit: Double, spent: Double, cash: Double, completion:@escaping (_ result: String) -> Void) {
        
        var creditToSave = credit
        var cashToSave = cash
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Session", in: managedContext)!
        let session = NSManagedObject(entity: entity, insertInto: managedContext)
        
        if spent > budget {
            creditToSave = spent - budget
            cashToSave = budget
        } else {
            cashToSave = spent
        }
        
        session.setValue(dateToday(), forKeyPath: "date")
        session.setValue(toMoney(rawMoney: budget), forKeyPath: "budget")
        session.setValue(toMoney(rawMoney: creditToSave), forKeyPath: "credit")
        session.setValue(toMoney(rawMoney: spent), forKeyPath: "total")
        session.setValue(toMoney(rawMoney: cashToSave), forKeyPath: "cash")
        
        do {
            try managedContext.save()
            sessions.append(session)
            
            completion("done")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteSessionLocally(session: NSManagedObject) {
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(session)
        do {
            try managedContext.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }
}
