//
//  SplitRulePersonTableViewCell.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

class SplitRulePersonTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var suffixLabel: UILabel!
    var delegate: SplitRulePersonTableViewCellDelegate?
    
    @IBAction func validateNumber(_ sender: UITextField) {
        if let text = numberTextField.text, Double(text) == nil {
            numberTextField.text = String(text.dropLast())
        }
    }
    
    @IBAction func didEndEditing(_ sender: UITextField) {
        if let text = numberTextField.text, let value = Double(text), numberTextField.keyboardType == .decimalPad {
            numberTextField.text = String(format: "%.2f", value)
        }
        delegate?.didEndEditing(cell: self, text: numberTextField.text ?? "")
    }
}

protocol SplitRulePersonTableViewCellDelegate {
    func didEndEditing(cell: UITableViewCell, text: String)
}
