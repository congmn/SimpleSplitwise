//
//  SplitRuleViewController.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

enum SplitRule: Int, CaseIterable {
    case equally
    case exactAmount
    case adjustment
    case percent
    case share
    
    var text: String {
        let allTexts = ["Equally", "Exact Amount", "Adjustment", "Percent", "Share"]
        return allTexts[rawValue]
    }
}

class SplitRuleViewController: UIViewController {

    @IBOutlet weak var ruleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var detailLabel: UILabel!
    
    var delegate: SelectSplitRuleDelegate?
    var selectedGroup: Group?
    var selectedAmount: Double?
    var selectedRule: Int?
    var selectedRuleDetails: String?
    private var people: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        people = (selectedGroup?.members?.allObjects as? [Person])?.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) ?? []
        setupRuleSegmentedControl()
        setupDetailLabel()
        updateDetailLabel(ruleDetailsArray: selectedRuleDetails?.components(separatedBy: Constants.ruleDetailSeparator) ?? [])
    }
    
    @IBAction func saveRule(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        guard let rule = selectedRule else {
            AlertController.shared.showMessageAlert(message: "No rule selected")
            return
        }
        if rule == SplitRule.equally.rawValue {
            delegate?.didSelect(rule: rule, ruleDetails: "")
            AlertController.shared.showMessageAlert(message: "Success")
            return
        }
        guard let ruleDetails = selectedRuleDetails else {
            AlertController.shared.showMessageAlert(message: "Please input some rule details")
            return
        }
        let ruleDetailsArray = ruleDetails.components(separatedBy: Constants.ruleDetailSeparator)
        switch rule {
        case SplitRule.exactAmount.rawValue:
            if getTotalDoubleStringOfAllTextFields(ruleDetailsArray: ruleDetailsArray) != getSelectedAmountString() {
                AlertController.shared.showMessageAlert(message: "Total exact amounts of all people is not equal to selected amount. Please change it before saving.")
                return
            }
        case SplitRule.adjustment.rawValue:
            if getTotalDoubleStringOfAllTextFields(ruleDetailsArray: ruleDetailsArray) > getSelectedAmountString() {
                AlertController.shared.showMessageAlert(message: "Total adjustments of all people is exceeding selected amount. Please change it before saving.")
                return
            }
        case SplitRule.percent.rawValue:
            if getTotalIntValueOfAllTextFields(ruleDetailsArray: ruleDetailsArray) != 100 {
                AlertController.shared.showMessageAlert(message: "Total percentages of all people is not equal to 100%. Please change it before saving.")
                return
            }
        case SplitRule.share.rawValue:
            if getTotalIntValueOfAllTextFields(ruleDetailsArray: ruleDetailsArray) == 0 {
                AlertController.shared.showMessageAlert(message: "There are no shares. Please change it before saving.")
                return
            }
        default:
            break
        }
        delegate?.didSelect(rule: rule, ruleDetails: ruleDetails)
        AlertController.shared.showMessageAlert(message: "Success")
    }
    
    @IBAction func ruleChanged(_ sender: UISegmentedControl) {
        selectedRule = sender.selectedSegmentIndex
        selectedRuleDetails = nil
        setupDetailLabel()
        updateDetailLabel(ruleDetailsArray: [])
        tableView.reloadData()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func setupRuleSegmentedControl() {
        if let selectedRule = selectedRule {
            ruleSegmentedControl.selectedSegmentIndex = selectedRule
        } else {
            ruleSegmentedControl.selectedSegmentIndex = 0
            selectedRule = 0
        }
    }
    
    private func setupDetailLabel() {
        if let selectedRule = selectedRule, selectedRule == SplitRule.exactAmount.rawValue || selectedRule == SplitRule.percent.rawValue {
            detailLabel.isHidden = false
        } else {
            detailLabel.isHidden = true
        }
    }
    
    private func setupNumberTextField(cell: SplitRulePersonTableViewCell, index: Int, rule: SplitRule) {
        cell.numberTextField.isHidden = rule == .equally
        cell.numberTextField.keyboardType = (rule == .percent || rule == .share) ? .numberPad : .decimalPad
        guard let selectedRuleDetails = selectedRuleDetails, rule != .equally else {
            cell.numberTextField.text = ""
            return
        }
        let valueString = selectedRuleDetails.components(separatedBy: Constants.ruleDetailSeparator)[index]
        cell.numberTextField.text = valueString
    }
    
    private func updateDetailLabel(ruleDetailsArray: [String]) {
        let index = ruleSegmentedControl.selectedSegmentIndex
        switch index {
        case SplitRule.exactAmount.rawValue:
            let selectedAmountString = getSelectedAmountString()
            let totalAmountString = getTotalDoubleStringOfAllTextFields(ruleDetailsArray: ruleDetailsArray)
            detailLabel.text = "$\(totalAmountString) out of $\(selectedAmountString)"
        case SplitRule.percent.rawValue:
            let totalPercentage = getTotalIntValueOfAllTextFields(ruleDetailsArray: ruleDetailsArray)
            detailLabel.text = "\(totalPercentage)% out of 100%"
        default:
            break
        }
    }
    
    private func getSelectedAmountString() -> String {
        return String(format: "%.2f", selectedAmount ?? 0.0)
    }
    
    private func getTotalDoubleStringOfAllTextFields(ruleDetailsArray: [String]) -> String {
        let totalAmountTimes100 = ruleDetailsArray.map({ Int(((Double($0) ?? 0.0) * 100).rounded()) }).reduce(0, +)
        return String(format: "%.2f", Double(totalAmountTimes100) / 100)
    }
    
    private func getTotalIntValueOfAllTextFields(ruleDetailsArray: [String]) -> Int {
        return ruleDetailsArray.map({ Int($0) ?? 0 }).reduce(0, +)
    }
}

// MARK: - Table view data source

extension SplitRuleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SplitRulePersonCell", for: indexPath) as? SplitRulePersonTableViewCell else {
            return UITableViewCell()
        }
        cell.nameLabel.text = people[indexPath.row].name
        let rule = SplitRule.allCases[ruleSegmentedControl.selectedSegmentIndex]
        setupNumberTextField(cell: cell, index: indexPath.row, rule: rule)
        switch rule {
        case .equally:
            cell.prefixLabel.text = ""
            cell.suffixLabel.text = ""
        case .exactAmount:
            cell.prefixLabel.text = "$"
            cell.suffixLabel.text = ""
        case .adjustment:
            cell.prefixLabel.text = "+"
            cell.suffixLabel.text = ""
        case .percent:
            cell.prefixLabel.text = ""
            cell.suffixLabel.text = "%"
        case .share:
            cell.prefixLabel.text = ""
            cell.suffixLabel.text = "shares"
        }
        cell.delegate = self
        return cell
    }
}

// MARK: - Table view cell delegate

extension SplitRuleViewController: SplitRulePersonTableViewCellDelegate {
    func didEndEditing(cell: UITableViewCell, text: String) {
        guard let rowIndex = tableView.indexPath(for: cell)?.row else { return }
        var ruleDetailsArray = Array(repeating: "", count: people.count)
        if let selectedRuleDetails = selectedRuleDetails {
            ruleDetailsArray = selectedRuleDetails.components(separatedBy: Constants.ruleDetailSeparator)
        }
        ruleDetailsArray[rowIndex] = text
        selectedRuleDetails = ruleDetailsArray.joined(separator: Constants.ruleDetailSeparator)
        updateDetailLabel(ruleDetailsArray: ruleDetailsArray)
    }
}

// MARK: - Select split rule delegate

protocol SelectSplitRuleDelegate {
    func didSelect(rule: Int, ruleDetails: String)
}
