//
//  AddBillTableViewController.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

class AddBillTableViewController: UITableViewController {
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectedGroupLabel: UILabel!
    @IBOutlet weak var selectedPaidPersonLabel: UILabel!
    @IBOutlet weak var selectedAmountLabel: UILabel!
    @IBOutlet weak var selectedRuleLabel: UILabel!
    
    private let datePickerIndexPath = IndexPath(row: 1, section: 1)
    private let amountIndexPath = IndexPath(row: 2, section: 2)
    private var isDatePickerShown: Bool = false {
        didSet {
            datePicker.isHidden = !isDatePickerShown
        }
    }
    private var selectedGroup: Group?
    private var selectedPaidPerson: Person?
    private var selectedAmount: Double?
    private var selectedRule: Int?
    private var selectedRuleDetails: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.date = Calendar.current.startOfDay(for: Date())
        updateDateViews()
        updateLabels()
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
    }
    
    @IBAction func saveBill(_ sender: UIButton) {
        guard let name = descriptionTextField.text else {
            AlertController.shared.showMessageAlert(message: "Please add a description first")
            return
        }
        guard let group = selectedGroup,
            let paidPerson = selectedPaidPerson,
            let amount = selectedAmount,
            let rule = selectedRule,
            let ruleDetails = selectedRuleDetails else {
            AlertController.shared.showMessageAlert(message: "Not enough details for splitting. Please fill out the missing details.")
            return
        }
        guard amount > 0 else {
            AlertController.shared.showMessageAlert(message: "Amount must be greater than zero")
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let bill = Bill(context: context)
        bill.name = name
        bill.date = datePicker.date
        bill.group = group
        bill.paidPerson = paidPerson
        bill.amount = amount
        bill.rule = Int16(rule)
        bill.ruleDetails = ruleDetails
        appDelegate.saveContext()
        resetBill()
        AlertController.shared.showMessageAlert(message: "Success")
    }
    
    private func updateDateViews() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    private func updateLabels() {
        selectedGroupLabel.text = selectedGroup?.name ?? "Not Set"
        selectedPaidPersonLabel.text = selectedPaidPerson?.name ?? "Not Set"
        if let amount = selectedAmount {
            selectedAmountLabel.text = "$" + String(format: "%.2f", amount)
        } else {
            selectedAmountLabel.text = "$0.00"
        }
        if let ruleIndex = selectedRule {
            selectedRuleLabel.text = SplitRule.allCases[ruleIndex].text
        } else {
            selectedRuleLabel.text = "Not Set"
        }
    }
    
    private func resetBill() {
        descriptionTextField.text = ""
        selectedGroup = nil
        selectedPaidPerson = nil
        selectedAmount = nil
        selectedRule = nil
        selectedRuleDetails = nil
        updateLabels()
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "SelectPaidPerson" && selectedGroup == nil {
            AlertController.shared.showMessageAlert(message: "Select group first")
            return false
        }
        if identifier == "SelectSplitRule" && (selectedGroup == nil || selectedAmount == nil || selectedAmount == 0.0) {
            AlertController.shared.showMessageAlert(message: "Select group and a positive amount first")
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectGroup", let destination = segue.destination as? SelectGroupTableViewController {
            destination.delegate = self
            destination.selectedGroup = selectedGroup
        }
        if segue.identifier == "SelectPaidPerson", let destination = segue.destination as? SelectPaidPersonTableViewController {
            destination.delegate = self
            destination.selectedGroup = selectedGroup
            destination.selectedPaidPerson = selectedPaidPerson
        }
        if segue.identifier == "SelectSplitRule", let destination = segue.destination as? SplitRuleViewController {
            destination.delegate = self
            destination.selectedGroup = selectedGroup
            destination.selectedAmount = selectedAmount
            destination.selectedRule = selectedRule
            destination.selectedRuleDetails = selectedRuleDetails
        }
    }
}

// MARK: - Table view delegate

extension AddBillTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return isDatePickerShown ? 216.0 : 0.0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case IndexPath(row: datePickerIndexPath.row - 1, section: datePickerIndexPath.section):
            isDatePickerShown = !isDatePickerShown
            tableView.beginUpdates()
            tableView.endUpdates()
        case amountIndexPath:
            AlertController.shared.showInputAlert(title: "Amount", message: "", confirmTitle: "Save", cancelTitle: "Cancel", keyboardType: .decimalPad, placeholder: "0.00") { [weak self] (confirmed, text) in
                if confirmed, let stringValue = text, let value = Double(stringValue) {
                    self?.selectedAmount = (value * 100).rounded() / 100
                    self?.selectedRule = nil
                    self?.selectedRuleDetails = nil
                    self?.updateLabels()
                }
            }
        default:
            break
        }
    }
}

// MARK: - Text field delegate

extension AddBillTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// MARK: - Select group delegate

extension AddBillTableViewController: SelectGroupTableViewControllerDelegate {
    func didSelect(group: Group) {
        guard group != selectedGroup else { return }
        selectedGroup = group
        selectedPaidPerson = nil
        selectedRule = nil
        selectedRuleDetails = nil
        updateLabels()
    }
}

// MARK: - Select paid person delegate

extension AddBillTableViewController: SelectPaidPersonTableViewControllerDelegate {
    func didSelect(person: Person) {
        selectedPaidPerson = person
        updateLabels()
    }
}

// MARK: - Select split rule delegate

extension AddBillTableViewController: SelectSplitRuleDelegate {
    func didSelect(rule: Int, ruleDetails: String) {
        selectedRule = rule
        selectedRuleDetails = ruleDetails
        updateLabels()
    }
}
