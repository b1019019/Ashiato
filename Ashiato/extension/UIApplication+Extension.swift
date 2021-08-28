//
//  UIApplication+Extension.swift
//  Ashiato
//
//  Created by Hajime Ito on 2021/08/28.
//

import UIKit

// MARK: 最前面のUIViewController/UINavigationControllerの取得
public extension UIApplication {
    var topViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        guard var topViewController = keyWindow?.rootViewController else { return nil }

        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }


    var topNavigationController: UINavigationController? {
        topViewController as? UINavigationController
    }
}
