//
//  FirstViewController.swift
//  ARtest
//
//  Created by ichinose-PC on 2024/09/02.
//

import Foundation
import UIKit



class FirstViewController : UIViewController
{
    var playerNum = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func playerNumBtnAction(_ sender: Any)
    {
        for subview in self.view.subviews
        {
            if let btn = subview as? UIButton
            {
                btn.isSelected = false
            }
        }
        
        if let btn = sender as? UIButton
        {
            btn.isSelected = true
            self.playerNum = btn.tag
        }
    }
    
    @IBAction func startBtnAction(_ sender: Any)
    {
        
        if (self.playerNum == -1)
        {
            AlertUtil.showAlert(title: "ERROR", message: "人数を選択してください", viewController: self)
            
            return
        }
        self.performSegue(withIdentifier: "togame", sender: self)
    }
    
    
}
