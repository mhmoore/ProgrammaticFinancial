//
//  UIViewController+AlertExt.swift
//  M1Assessment
//
//  Created by Michael Moore on 10/10/21.
//

import UIKit

extension UIViewController {
    func displayErrorAlert(altTitle: String? = nil,
                           altMessage: String? = nil,
                           altActionTitle: String? = nil,
                           completion: (() -> Void)? = nil) {
        
        let title = altTitle ?? "Uh-oh!"
        let message = altMessage ?? "Looks like something didn't quite work right. Sorry about that. Please try again in a little bit."
        let actionTitle = altActionTitle ?? "Ok"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: actionTitle , style: .cancel) { _ in
            if let completion = completion {
                completion()
            }
        }
        alertController.addAction(dismiss)
        
        present(alertController, animated: true)
    }
}
