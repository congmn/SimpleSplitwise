//
//  UIApplication+Extension.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController) -> UIViewController? {
        switch base {
        case let navigationController as UINavigationController:
            return topViewController(base: navigationController.visibleViewController)
        case let tabBarController as UITabBarController:
            return topViewController(base: tabBarController.selectedViewController)
        default:
            break
        }
        if let presentedViewController = base?.presentedViewController {
            return topViewController(base: presentedViewController)
        }
        return base
    }
}
