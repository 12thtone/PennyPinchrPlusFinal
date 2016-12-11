//
//  ViewController.swift
//  PennyPinchr
//
//  Created by Matt Maher on 12/9/16.
//  Copyright © 2016 MMMD. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var moneyField: UITextField!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var taxPicker: UIPickerView!
    
    var delegate: SessionDelegate?
    
    var budget = 0.0
    var spent = 0.0
    var remaining = 0.0
    var lastItem = 0.0
    var cash = 0.0
    var credit = 0.0
    
    var taxL = 0
    var taxR = 0
    var tax = 0.0
    
    var budgetSaved = false
    var hasCreditCard = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.navigationBar.isHidden = true
        
        taxPicker.delegate = self
        taxPicker.dataSource = self
        
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        spentLabel.isHidden = true
        remainingLabel.isHidden = true
        
        moneyField.placeholder = "Enter Budget"
        enterButton.setTitle("Save Budget", for: .normal)
        
        let keyboardTapDismiss = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        view.addGestureRecognizer(keyboardTapDismiss)
    }
    
    func changeViews() {
        spentLabel.text = DataService.ds.toMoney(rawMoney: spent)
        
        if hasCreditCard {
            remainingLabel.text = "Cash: \(DataService.ds.toMoney(rawMoney: budget)) - Credit: \(DataService.ds.toMoney(rawMoney: spent - budget))"
        } else {
            remainingLabel.text = DataService.ds.toMoney(rawMoney: remaining)
        }
        moneyField.text = ""
    }
    
    func showMoneyLabels() {
        spentLabel.isHidden = false
        remainingLabel.isHidden = false
    }

    @IBAction func enterTapped(_ sender: Any) {
        if moneyField.text != "" && budgetSaved == false {
            budget = Double(moneyField.text!)!
            remaining = budget
            
            budgetSaved = true
            
            moneyField.placeholder = "Enter Purchase Price"
            enterButton.setTitle("Save Purchase", for: .normal)
            
            changeViews()
            showMoneyLabels()
        } else if moneyField.text != "" && budgetSaved == true {
            lastItem = DataService.ds.priceWithTax(rawPrice: Double(moneyField.text!)!, tax: tax)
            spent += lastItem
            remaining = budget - spent
            
            changeViews()
        } else {
            emptyFieldAlert()
        }
        
        if remaining < 0 {
            overBudget()
        }
    }
    
    func overBudget() {
        spentLabel.textColor = UIColor.red
        remainingLabel.textColor = UIColor.red
        
        enterButton.setTitle("Be Careful", for: .normal)
        
        overBudgetAlert()
    }
    
    func underBudget() {
        spentLabel.textColor = UIColor.black
        remainingLabel.textColor = UIColor.black
        
        enterButton.setTitle("Save Purchase", for: .normal)
        
        spent -= lastItem
        remaining = budget - spent
        
        changeViews()
    }

    func emptyFieldAlert() {
        let alertController = UIAlertController(title: "Oops!", message: "Please enter some money into the field.", preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
    
    func overBudgetAlert() {
        let alertController = UIAlertController(title: "Uh oh...", message: "This one's going to put you over budget!", preferredStyle: .actionSheet)
        
        let ccAction = UIAlertAction(title: "Use Credit Card", style: .default) { (action) in
            self.hasCreditCard = true
            self.changeViews()
        }
        alertController.addAction(ccAction)
        
        let cancelAction = UIAlertAction(title: "Back to the Shelf", style: .cancel) { (action) in
            self.underBudget()
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            
        }
    }
    
    // PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 || component == 3 {
            return 1
        }
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return "."
        } else if component == 3 {
            return "%"
        }
        return "\(DataService.ds.taxArray()[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            taxL = DataService.ds.taxArray()[row]
        } else if component == 2 {
            taxR = DataService.ds.taxArray()[row]
        }
        
        tax = Double("\(taxL).\(taxR)")!
        
        taxLabel.text = "Tax: \(tax)%"
    }
    
    // Other stuff
    
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        budget = 0.0
        spent = 0.0
        remaining = 0.0
        lastItem = 0.0
        
        budgetSaved = false
        hasCreditCard = false
        
        setupViews()
    }
    
    // Save
    
    @IBAction func saveTapped(_ sender: Any) {
        DataService.ds.saveSessionLocally(budget: budget, credit: credit, spent: spent, cash: cash) {
            (result: String) in
            
            print(result)
            
            self.closeSession()
        }
    }
    
    func closeSession() {
        self.dismiss(animated: true, completion: nil)
        delegate?.reloadSessions()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

