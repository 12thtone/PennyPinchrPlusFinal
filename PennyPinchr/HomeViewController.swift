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
    
    var sessions = [SessionModel]()
    var savedSessions = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadSessions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSessions() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Session")
        
        savedSessions.removeAll()
        sessions.removeAll()
        
        do {
            savedSessions = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for savedSession in savedSessions {
            let session = SessionModel.init(session: savedSession)
            sessions.append(session)
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
        loadSessions()
    }
    
    @IBAction func addShopSession(_ sender: Any) {
        let sessionVC = self.storyboard?.instantiateViewController(withIdentifier: "SessionVC") as! ViewController
        sessionVC.delegate = self
        let navController = UINavigationController(rootViewController: sessionVC)
        
        self.present(navController, animated: true, completion: nil)
    }

    
}
