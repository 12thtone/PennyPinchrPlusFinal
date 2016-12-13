//
//  HomeViewController.swift
//  PennyPinchr
//
//  Created by Matt Maher on 12/10/16.
//  Copyright © 2016 MMMD. All rights reserved.
//

import UIKit
import CoreData

protocol SessionDelegate {
    func reloadSessions()
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SessionDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    
    var sessions = [SessionModel]()
    var budget = [BudgetModel]()
    var savedSessions = [NSManagedObject]()
    var savedBudget = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if budget.isEmpty {
            newUserBudget()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Session")
        let fetchRequestBudget = NSFetchRequest<NSManagedObject>(entityName: "Budget")
        
        savedSessions.removeAll()
        sessions.removeAll()
        
        // Get Sessions
        
        do {
            savedSessions = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for savedSession in savedSessions {
            let session = SessionModel.init(session: savedSession)
            sessions.append(session)
        }
        
        // Get Budget
        
        do {
            savedBudget = try managedContext.fetch(fetchRequestBudget)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for onlyBudget in savedBudget {
            let theOnlyBudget = BudgetModel.init(curBudget: onlyBudget)
            budget.append(theOnlyBudget)
        }
        
        if savedBudget.isEmpty == false {
            budget.append(BudgetModel.init(curBudget: savedBudget.first!))
        }
        
        setViews()
    }
    
    func setViews() {
        if budget.isEmpty {
            budgetLabel.text = "Period Budget: $0.00"
        } else {
            budgetLabel.text = "Period Budget: \(DataService.ds.toMoney(rawMoney: Double(budget.first!.budget)!))"
        }
        
        if sessions.isEmpty {
            spentLabel.text = "Period Spent: $0.00"
        } else {
            spentLabel.text = "Period Spent: \(DataService.ds.toMoney(rawMoney: Double(DataService.ds.totalSpent(sessions: sessions))!))"
        }
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let session = sessions[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as? HomeTableViewCell {
            cell.dateLabel.text = "\(session.date)"
            cell.totalLabel.text = "Total Spent: \(session.total)"
            cell.cashLabel.text = "Cash: \(session.cash)"
            cell.creditLabel.text = "Credit: \(session.credit)"
            
            return cell
        }
        return HomeTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataService.ds.deleteSessionLocally(session: savedSessions[indexPath.row])
            sessions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func reloadSessions() {
        loadData()
    }
    
    @IBAction func addShopSession(_ sender: Any) {
        let sessionVC = self.storyboard?.instantiateViewController(withIdentifier: "SessionVC") as! ViewController
        sessionVC.delegate = self
        let navController = UINavigationController(rootViewController: sessionVC)
        
        self.present(navController, animated: true, completion: nil)
    }

    @IBAction func calenderTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "New Budget Period", message: "Time for a new budged period?\n\nCreating a new one will clear the old.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "$0.00"
            textField.keyboardType = .numbersAndPunctuation
        }
        
        let okAction = UIAlertAction(title: "Create New Budget", style: .default) { (action) in
            self.addNewBudget(newBudget: (alertController.textFields?[0].text)!)
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            
        }
    }
    
    func addNewBudget(newBudget: String) {
        DataService.ds.saveBudgetLocally(budget: newBudget) {
            (result: String) in
            
            print(result)
            self.budgetLabel.text = "Period Budget: \(DataService.ds.toMoney(rawMoney: Double(newBudget)!))"
            self.spentLabel.text = "Period Spent: $0.00"
        }
    }
    
    func newUserBudget() {
        let alertController = UIAlertController(title: "Welcome to PennyPinchr!", message: "To get started, please enter your budget for this period.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "$0.00"
            textField.keyboardType = .numbersAndPunctuation
        }
        
        let okAction = UIAlertAction(title: "Create Budget", style: .default) { (action) in
            self.addNewBudget(newBudget: (alertController.textFields![0].text)!)
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true) {
            
        }
    }
}
