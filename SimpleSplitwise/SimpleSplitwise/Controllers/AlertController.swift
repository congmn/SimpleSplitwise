//
//  AlertController.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

class AlertController: NSObject {
    static let shared = AlertController()
    var alertController: UIAlertController?
    
    func showInputAlert(title: String, message: String, confirmTitle: String, cancelTitle: String, keyboardType: UIKeyboardType, placeholder: String, completionHandler: @escaping (_ confirmed: Bool, _ text: String?) -> Void) {
        if alertController != nil {
            alertController?.dismiss(animated: true, completion: nil)
            alertController = nil
        }
        
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { [weak self] _ in
            let text = self?.alertController?.textFields?.first?.text
            self?.alertController = nil
            completionHandler(true, text)
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { [weak self] _ in
            self?.alertController = nil
            completionHandler(false, nil)
        }
        alertController?.addAction(confirmAction)
        alertController?.addAction(cancelAction)
        alertController?.addTextField { textField in
            textField.keyboardType = keyboardType
            textField.placeholder = placeholder
        }
        
        if alertController != nil {
            UIApplication.topViewController()?.present(alertController!, animated: true, completion: nil)
        }
    }
}
