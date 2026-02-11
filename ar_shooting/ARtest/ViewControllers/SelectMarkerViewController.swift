//
//  SelectMarkerViewController.swift
//  ARtest
//
//  Created by ichinose-PC on 2026/02/10.
//

import UIKit

class SelectMarkerViewController : UIViewController
{
    
    @IBOutlet weak var player1Btn: UIButton!
    @IBOutlet weak var player2Btn: UIButton!
    @IBOutlet weak var player3Btn: UIButton!
    @IBOutlet weak var player4Btn: UIButton!
    var players: [UIButton] = []
    
    @IBOutlet weak var player1View: UIView!
    @IBOutlet weak var player2View: UIView!
    @IBOutlet weak var player3View: UIView!
    @IBOutlet weak var player4View: UIView!
    var playerViews: [UIView] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        players = [self.player1Btn, self.player2Btn, self.player3Btn, self.player4Btn]
        playerViews = [self.player1View, self.player2View, self.player3View, self.player4View]
        let playerNum = ShareData.shared.playerNum
        
        for i in self.players
        {
            i.isEnabled = false
            i.alpha = 0.3
        }
        
        for i in players.prefix(playerNum)
        {
            i.isEnabled = true
            i.alpha = 1.0
        }
        
    }
    
    @IBAction func player1Btn(_ sender: Any)
    {
        for i in self.playerViews
        {
            i.backgroundColor = UIColor.csblack
        }
        self.player1View.backgroundColor = UIColor.csred
        ShareData.shared.id = 1
    }
    
    @IBAction func player2Btn(_ sender: Any)
    {
        for i in self.playerViews
        {
            i.backgroundColor = UIColor.csblack
        }
        self.player2View.backgroundColor = UIColor.csblue
        ShareData.shared.id = 2
    }
    
    @IBAction func player3Btn(_ sender: Any)
    {
        for i in self.playerViews
        {
            i.backgroundColor = UIColor.csblack
        }
        self.player3View.backgroundColor = UIColor.cspurple
        ShareData.shared.id = 3
    }
    
    @IBAction func player4Btn(_ sender: Any)
    {
        self.player4View.backgroundColor = UIColor.csorenge
        ShareData.shared.id = 4
    }
    
    @IBAction func JoinGameBtnAction(_ sender: Any)
    {

        
        if (ShareData.shared.id == 0)
        {
            AlertUtil.showAlert(title: "ERROR", message: "マーカーを選択してください", viewController: self)
            
            return
        }
        self.performSegue(withIdentifier: "toGame", sender: self)
    }
    
}
