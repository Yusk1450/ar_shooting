//
//  ViewController.swift
//  ARtest
//
//  Created by ichinose-PC on 2024/05/17.
//

import UIKit
import SceneKit
import ARKit
import Alamofire
import SwiftyJSON

enum ItemType: Int
{
    case None = -1
    case Attack = 0
    case Guard = 1
    case Heal = 2
}

class ViewController: UIViewController, ARSCNViewDelegate,UIGestureRecognizerDelegate {

    var timer: Timer?
    let HP = [-1,-1,-1,-1]
    let items:[ItemType] = [.Attack, .Guard, .Heal]
    let itemImageName = ["item_attack_icon", "item_guard_icon", "item_heel_icon_02"]
    let itemBackline = ["item_attack_back_off", "item_guard_back_off", "item_heel_icon"]
    // 表示されているアイテム
    var appearanceItem:ItemType = .None
    // 所持しているアイテム
    var currentItem:ItemType = .None
    
    var Life:Double = 100.0
    var winid = 0
    
    var HPWight:Double = 100
    var id:Int = 3
    var HPdif:Double = 0
    
    var target_id = 0
    
    var playerNum = 3
    
    @IBOutlet weak var Pause: UIImageView!
    @IBOutlet weak var HPber: UIView!
    
    var iconBackY:CGFloat!
    
    @IBOutlet weak var icon_Line: UIImageView!
    var ItemUse:Bool = false
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var icon_back: UIView!
    
    @IBOutlet weak var gameview: UIImageView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if id == 1{
            gameview.image = UIImage(named: "game_back_1p")
        }
        else if id == 2{
            gameview.image = UIImage(named: "game_back_2p")
        }
        else if id == 3{
            gameview.image = UIImage(named: "game_back_3p")
        }
        else if id == 4{
            gameview.image = UIImage(named: "game_back_4p")
        }
        startFetchingData()
        Pause.isHidden = true
        sceneView.delegate = self
        
        self.icon.image = UIImage(named: "item_no_icon")
        self.icon_Line.image = UIImage(named: "")
        icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(_:))))
        
        self.iconBackY = self.icon_back.frame.origin.y
        self.HPWight = HPber.frame.width
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tapRecognizer.delegate = self
        sceneView.addGestureRecognizer(tapRecognizer)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // first see if there is a folder called "ARImages" Resource Group in our Assets Folder
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "ARResources", bundle: Bundle.main) {
            
            // if there is, set the images to track
            configuration.trackingImages = trackedImages
            // at any point in time, only 1 image will be tracked
            configuration.maximumNumberOfTrackedImages = trackedImages.count
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toresult" {
                let ResultViewController = segue.destination as! ResultViewController
                ResultViewController.id = self.id
                ResultViewController.winid = self.winid
                ResultViewController.playerNum = self.playerNum            }
        }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // if the anchor is not of type ARImageAnchor (which means image is not detected), just return
        guard let imageAnchor = anchor as? ARImageAnchor else {return}
        
        //コンテンツ表示
        let imageName = imageAnchor.referenceImage.name

        // 検出された画像の物理サイズに合わせて平面を作成
        let plane = SCNPlane(
            width: imageAnchor.referenceImage.physicalSize.width,
            height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIImage(named: "barng_target")
        
        if imageName == "items"
        {
            if let randitem = self.items.randomElement()
            {
                self.appearanceItem = randitem
                plane.firstMaterial?.diffuse.contents = UIImage(named: self.itemImageName[randitem.rawValue])
            }
        }
                
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -Float.pi / 2
            
        // 画像に関連付けられたノードに名前を設定
        planeNode.name = imageName
        node.addChildNode(planeNode)
    }
    func startFetchingData() 
    {

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.HPAPI()
            }
        }
    
    func HPAPI() {
        Alamofire.request("https://yusk1450.sakura.ne.jp/barng/life?room_id=1").responseJSON { response in
            switch response.result {
            case .success:
                if let data = response.data {
                    
                    let json = JSON(data)
                    print(json)
                    
                    var lifeCount = 0
                    var count = 0
                    for item in json.arrayValue
                    {
                        count += 1
                        
                        if item["life"].doubleValue <= 0.0
                        {
                            lifeCount += 1
                        }
                        else
                        {
                            self.winid = item["user_id"].intValue
                            print("winid",self.winid)
                        }
                        
                        if (count == self.playerNum)
                        {
                            break
                        }
                    }
                    
                    if (lifeCount == self.playerNum - 1)
                    {
                        print("ゲーム終了")
                        self.timer?.invalidate()
                        self.performSegue(withIdentifier: "toresult", sender: self)
                    }

                    // JSON配列の中をループで検索
                    for item in json.arrayValue
                    {
                        // 自分のIDと一致するか確認
                        if item["user_id"].intValue == self.id
                        {
                            if item["life"].doubleValue !=  self.Life
                            {
                                self.HPdif = item["life"].doubleValue
                                self.HPset()
                                print("Life",self.HPdif)
                                return
                            }

                            break
                        }
                    }
                    
                    
                }
            case .failure(let error):
                print("エラー: \(error)")
            }
        }
    }
    
    func HPset()
    {
        let damageview = UIView()
        
        damageview.isUserInteractionEnabled = false
        damageview.frame = CGRect(x: 0, y: 0, width: 852, height: 393)
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        self.view.addSubview(damageview)
        if self.HPdif >= self.Life
        {
            damageview.backgroundColor = UIColor.green.withAlphaComponent(0.5)
            UIView.animate(withDuration: 0.7, animations: {
                damageview.backgroundColor =  UIColor.red.withAlphaComponent(0)
            }) { finished in
                if finished
                {
                    damageview.removeFromSuperview()
                }
            }
            
        }
        
        else if HPdif <= self.Life
        {
            damageview.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            UIView.animate(withDuration: 0.7, animations: {
                damageview.backgroundColor =  UIColor.red.withAlphaComponent(0)
            }) { finished in
                if finished
                {
                    damageview.removeFromSuperview()
                }
            }
        }
        self.Life = self.HPdif
        
        let lifePercentage = Life / 100.0
        let newWidth = HPWight * lifePercentage
        var frame = HPber.frame
            frame.size.width = newWidth
            HPber.frame = frame
        
        
        if Life <= 0
        {
            Pause.isHidden = false
            return
        }
        if Life >= 100
        {
            Life = 100
            return
        }
    }


    @IBOutlet weak var icon: UIImageView!
    
    @objc func tap(_ tapRecognizer: UITapGestureRecognizer)
    {
        let touchLocation = tapRecognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touchLocation, options: nil)
        
        if let hitNode = hitTestResults.first?.node {
            // ノードの名前を確認して、対応する処理を実行
            if let nodeName = hitNode.name
            {
                if nodeName == "player1"
                {
                    self.target_id = 1
                    self.damage()
                }
                else if nodeName == "player2"
                {
                    self.target_id = 2
                    self.damage()
                }
                else if nodeName == "player3"
                {
                    self.target_id = 3
                    self.damage()
                }
                else if nodeName == "player4"
                {
                    self.target_id = 4
                    self.damage()
                }
                else if nodeName == "items"
                {
                    if ItemUse
                    {
                        return
                    }
                    
                    if let randitem = self.items.randomElement(), let plane = hitNode.geometry as? SCNPlane {
                        
                        self.currentItem = self.appearanceItem
                        self.icon.image = UIImage(named: self.itemImageName[self.currentItem.rawValue])
                        self.icon_Line.image = UIImage(named: self.itemBackline[self.currentItem.rawValue])
                        
                        self.appearanceItem = randitem
                        plane.firstMaterial?.diffuse.contents = UIImage(named: self.itemImageName[randitem.rawValue])
                        
                    }
                }
            }
        }
    }
    func damage()
    {
        let url = "https://yusk1450.sakura.ne.jp/barng/damage"

                let parameters:[String: Any] = [
                    "room_id": 1,
                    "my_user_id": self.id,
                    "target_user_id": self.target_id
                ]
        
                Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
                    if let data = response.data
                    {
                        print(String(data: data, encoding: .utf8))
                    }
                }

            
    
    }
    
//    func damage()
//    {
//        let url = "https://yusk1450.sakura.ne.jp/barng/damage"
//
//                let parameters:[String: Any] = [
//                    "room_id": 1,
//                    "my_user_id": self.id,
//                    "target_user_id": self.target_id
//                ]
//        
//                Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
//                    if let data = response.data
//                    {
//                        print(String(data: data, encoding: .utf8))
//                    }
//                }
//
//            
//    
//    }
    
    @objc func iconTapped(_ sender: UITapGestureRecognizer)
    {
        if self.currentItem == .None
        {
            return
        }
        if self.ItemUse
        {
            return
        }
        self.ItemUse = true
        self.icon_back.frame.size.height = 60
        self.icon_back.frame.origin.y = self.iconBackY
        self.icon_Line.image = UIImage(named: "")
        
        

        if currentItem == .Attack
        {
            icon_back.backgroundColor = UIColor.csred
            self.item()
            UIView.animate(withDuration: 5.0, animations: {
                self.icon_back.frame.origin.y += 60.0
                self.icon_back.frame.size.height = 0
            }) { finished in
                if finished
                {
                    self.icon_back.backgroundColor = UIColor.clear
                    self.currentItem = .None
                    self.icon.image = UIImage(named: "item_no_icon")
                    self.ItemUse = false
                    self.item()
                    print(self.ItemUse)
                    
                }
            }
        }
        else if currentItem == .Guard
        {
            icon_back.backgroundColor = UIColor.csblue
            self.item()
            
            UIView.animate(withDuration: 5.0, animations: {
                self.icon_back.frame.origin.y += 60.0
                self.icon_back.frame.size.height = 0
            }) { finished in
                if finished
                {
                    
                    self.icon_back.backgroundColor = UIColor.clear
                    self.currentItem = .None
                    self.icon.image = UIImage(named: "item_no_icon")
                    self.ItemUse = false
                    self.item()
                    print(self.ItemUse)
                }
            }
        }
        else if currentItem == .Heal
        {
            recovery()
            self.icon_back.backgroundColor = UIColor.clear
            self.currentItem = .None
            self.icon.image = UIImage(named: "item_no_icon")
            self.ItemUse = false

        }

    }
    func item()
    {
        print("item",currentItem.rawValue)
        let url = "https://yusk1450.sakura.ne.jp/barng/item"

                let parameters:[String: Any] = [
                    "room_id": 1,
                    "user_id": self.id,
                    "item_id": self.currentItem.rawValue
                ]
        
                Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
                    if let data = response.data
                    {
                        print(String(data: data, encoding: .utf8))
                    }
                }

            
    
    }
    func recovery()
    {
        let url = "https://yusk1450.sakura.ne.jp/barng/recovery"

                let parameters:[String: Any] = [
                    "room_id": 1,
                    "user_id": self.id,
                ]
        
                Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
                    if let data = response.data
                    {
                        print(String(data: data, encoding: .utf8))
                    }
                }

            
    
    }
}
