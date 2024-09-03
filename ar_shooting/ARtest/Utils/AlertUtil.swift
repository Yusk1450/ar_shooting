//
//  AlertUtil.swift
//  ARtest
//
//  Created by ichinose-PC on 2024/09/03.
//

import UIKit

class AlertUtil: NSObject
{
    
    
    // クラスメソッド
    class func showAlert(title:String, message:String, viewController:UIViewController)
    {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK",
                                     style: .default)
        
        alert.addAction(okButton)
        
        viewController.present(alert, animated: true)
    }
}

