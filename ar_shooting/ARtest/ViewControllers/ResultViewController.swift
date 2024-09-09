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
    
    @IBOutlet weak var pick_1p: UIImageView!
    @IBOutlet weak var pick_2p: UIImageView!
    @IBOutlet weak var pick_3p: UIImageView!
    @IBOutlet weak var pick_4p: UIImageView!
    
    @IBOutlet weak var result_1p: UIImageView!
    @IBOutlet weak var result_2p: UIImageView!
    @IBOutlet weak var result_3p: UIImageView!
    @IBOutlet weak var result_4p: UIImageView!
    var pick = [UIImageView()]
    var win = [UIImageView()]
    var winname = ["result_win_1p","result_win_2p","result_win_3p","result_win_4p"]
    var id = 0
    var winid = 0
    var playerNum = 0
    override func viewDidLoad() {
        self.pick = [pick_1p,pick_2p,pick_3p,pick_4p]
        self.win = [result_1p,result_2p,result_3p,result_4p]
        self.pick[self.id - 1].isHidden = false
        self.win[self.winid - 1].image = UIImage(named: self.winname[self.winid - 1])
        if playerNum == 2
        {
            self.result_3p.isHidden = true
            self.result_4p.isHidden = true
        }
        if playerNum == 3
        {
            self.result_4p.isHidden = true

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
