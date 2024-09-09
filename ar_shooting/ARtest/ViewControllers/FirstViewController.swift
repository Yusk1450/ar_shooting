//
//  FirstViewController.swift
//  ARtest
//
//  Created by ichinose-PC on 2024/09/02.
//

import Foundation
import UIKit
import Alamofire




class FirstViewController : UIViewController
{
    var playerNum = -1
    var players = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = "https://yusk1450.sakura.ne.jp/barng/reset"

                let parameters:[String: Any] = [
                    "room_id": 1,
                ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
            if let data = response.data
            {
                print(String(data: data, encoding: .utf8))
            }
        }
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
            if self.playerNum == 2
            {
                players = 2
            }
            else if self.playerNum == 3
            {
                players = 3
            }
            else if self.playerNum == 4
            {
                AlertUtil.showAlert(title: "ERROR", message: "4人は選択できません", viewController: self)
                return
                //players = 4
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "togame" {
                let ViewController = segue.destination as! ViewController
                ViewController.playerNum = self.players
            }
        }
    
    
}
