//
//  ResultViewController.swift
//  ARtest
//
//  Created by ichinose-PC on 2024/09/03.
//

import Foundation
import UIKit
import Alamofire

class ResultViewController :UIViewController
{
    
    @IBOutlet weak var pick1p: UIImageView!
    @IBOutlet weak var pick2p: UIImageView!
    @IBOutlet weak var pick3p: UIImageView!
    @IBOutlet weak var pick4p: UIImageView!
    
    @IBOutlet weak var result1p: UIImageView!
    @IBOutlet weak var result2p: UIImageView!
    @IBOutlet weak var result3p: UIImageView!
    @IBOutlet weak var result4p: UIImageView!
    var pick = [UIImageView()]
    var win = [UIImageView()]
    var winName = ["result_win_1p","result_win_2p","result_win_3p","result_win_4p"]
    var id = 0
    var winId = 0
    var playerNum = 0
    override func viewDidLoad() {
        self.pick = [pick1p,pick2p,pick3p,pick4p]
        self.win = [result1p,result2p,result3p,result4p]
        self.pick[self.id - 1].isHidden = false
        self.win[self.winId - 1].image = UIImage(named: self.winName[self.winId - 1])
        if playerNum == 2
        {
            self.result3p.isHidden = true
            self.result4p.isHidden = true
        }
        if playerNum == 3
        {
            self.result4p.isHidden = true

        }
        
        
    }
    @IBAction func backhome(_ sender: Any) {
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

            
 
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
