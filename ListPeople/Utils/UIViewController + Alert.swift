//
//  UIViewController + Alert.swift
//  ListPeople
//
//  Created by Taha  YILMAZ on 23.08.2021.
//

import UIKit

extension UIViewController {
    func showAlert(buttonTitle: String = AppStrings.ok, message: String, handler: ((UIAlertAction)->Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: handler))
        self.present(alertController, animated: true, completion: nil)
    }
}
