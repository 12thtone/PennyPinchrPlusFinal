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
        return "\(moneyCommaFormat(rawMoney: String(format: "%.2f", rawMoney)))"
    }
    
    func toMoneyNDS(rawMoney: Double) -> String {
        return "\(String(format: "%.2f", rawMoney))"
    }
    
    func moneyDouble(rawString: String, charCount: Int) -> String {
        let cleanString = rawString.replacingOccurrences(of: "$", with: "")
        
        return "\(Double(cleanString)! / 100.0)"
    }
    
    func moneyCommaFormat(rawMoney: String) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        
        return formatter.string(from: NSNumber(value: Double(rawMoney)!))!
    }
    
    func cleanDoubleMoney(dirtyString: String) -> Double {
        return Double(dirtyString.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: ""))!
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
    
    func totalSpent(sessions: [SessionModel]) -> String {
        var spentString = 0.0
        
        for session in sessions {
            spentString += Double("\(session.total)")!
        }
        
        return "\(spentString)"
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
        session.setValue(toMoneyNDS(rawMoney: budget), forKeyPath: "budget")
        session.setValue(toMoneyNDS(rawMoney: creditToSave), forKeyPath: "credit")
        session.setValue(toMoneyNDS(rawMoney: spent), forKeyPath: "total")
        session.setValue(toMoneyNDS(rawMoney: cashToSave), forKeyPath: "cash")
        
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
    
    func saveBudgetLocally(budget: String, completion:@escaping (_ result: String) -> Void) {
        let entityName = "Budget"
        let budgetToSave = budget.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        let session = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try managedContext.execute(deleteRequest)
        } catch {
            print(error)
        }
        
        session.setValue(budgetToSave, forKeyPath: "currentBudget")
        
        do {
            try managedContext.save()
            sessions.append(session)
            
            completion(budgetToSave)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
