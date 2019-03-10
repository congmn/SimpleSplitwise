//
//  UIAlertController+Extension.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

extension UIAlertController {
    @objc func validateDoubleNumber() {
        if let text = textFields?.first?.text, Double(text) == nil {
            textFields?.first?.text = String(text.dropLast())
        }
    }
}
