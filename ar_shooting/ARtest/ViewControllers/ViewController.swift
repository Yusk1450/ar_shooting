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
import TapticEngine

enum ItemType: Int
{
    case None = -1
    case Attack = 0
    case Guard = 1
    case Heal = 2
}

class ViewController: UIViewController, ARSCNViewDelegate,UIGestureRecognizerDelegate {

    var timer: Timer?
    let hp = [-1,-1,-1,-1]
    let items:[ItemType] = [.Attack, .Guard, .Heal]
    let itemImageName = ["item_attack_icon", "item_guard_icon", "item_heel_icon_02"]
    let itemBackline = ["item_attack_back_off", "item_guard_back_off", "item_heel_icon"]
    // 表示されているアイテム
    var appearanceItem:ItemType = .None
    // 所持しているアイテム
    var currentItem:ItemType = .None
    
    var life = 100.0
    var winId = 0
    
    var hpWight = 100.0
    var id = ShareData.shared.id
    var hpDif = 0.0
    
    var targetId = 0
    
    @IBOutlet weak var pause: UIImageView!
    @IBOutlet weak var hpBar: UIView!
    
    var iconBackY:CGFloat!
    var hpBarWidthConstraint: NSLayoutConstraint?
    var hpBarLeadingOffset: CGFloat = 0
    var didSetupHPBarConstraints = false
    
    @IBOutlet weak var iconLine: UIImageView!
    var itemUse:Bool = false
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var iconBack: UIView!
    
    @IBOutlet weak var gameView: UIImageView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if id == 1{
            gameView.image = UIImage(named: "game_back_1p")
        }
        else if id == 2{
            gameView.image = UIImage(named: "game_back_2p")
        }
        else if id == 3{
            gameView.image = UIImage(named: "game_back_3p")
        }
        else if id == 4{
            gameView.image = UIImage(named: "game_back_4p")
        }
        startFetchingData()
        pause.isHidden = true
        sceneView.delegate = self
        

        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        gameView.contentMode = .scaleAspectFill
        gameView.clipsToBounds = true
        
        if let containerView = gameView.superview {
            for constraint in self.view.constraints {
                let isContainerLeading = (constraint.firstItem === containerView && constraint.firstAttribute == .leading)
                let isContainerTrailing = (constraint.firstItem === containerView && constraint.firstAttribute == .trailing)
                let isContainerBottom = (constraint.firstItem === containerView && constraint.firstAttribute == .bottom)
                if isContainerLeading || isContainerTrailing || isContainerBottom {
                    constraint.isActive = false
                }
            }
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        self.icon.image = UIImage(named: "item_no_icon")
        self.iconLine.image = UIImage(named: "")
        icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(_:))))
        
        self.iconBackY = self.iconBack.frame.origin.y
        self.hpWight = hpBar.frame.width
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        

        if !didSetupHPBarConstraints {
            setupHPBarConstraints()
            didSetupHPBarConstraints = true
        }
    }
    
    func setupHPBarConstraints() {
        guard let parentView = hpBar.superview else { return }
        
        // Storyboardの制約を無効化
        parentView.constraints.forEach { constraint in
            if (constraint.firstItem === hpBar && constraint.firstAttribute == .centerX) ||
               (constraint.firstItem === hpBar && constraint.firstAttribute == .width) {
                constraint.isActive = false
            }
        }
        
        let leadingOffset = parentView.bounds.width * (1.0 - 0.935897) / 2.0
        let leadingConstraint = NSLayoutConstraint(
            item: hpBar!, attribute: .leading,
            relatedBy: .equal,
            toItem: parentView, attribute: .leading,
            multiplier: 1.0,
            constant: leadingOffset
        )
        
        let widthConstraint = NSLayoutConstraint(
            item: hpBar!, attribute: .width,
            relatedBy: .equal,
            toItem: parentView, attribute: .width,
            multiplier: 0.935897,
            constant: 0
        )
        
        leadingConstraint.isActive = true
        widthConstraint.isActive = true
        
        hpBarWidthConstraint = widthConstraint
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
        
        sceneView.session.run(configuration)

    }
    
//    var didSetupHPBar = false
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        guard !didSetupHPBar else { return }
//        didSetupHPBar = true
//
//        let oldCenter = hpBar.center
//
//        hpBar.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
//
//        hpBar.center = oldCenter
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toresult" {
            let ResultViewController = segue.destination as! ResultViewController
            ResultViewController.id = self.id
            ResultViewController.winId = self.winId
            ResultViewController.playerNum = ShareData.shared.playerNum
        }
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
                    
                    var deadCount = 0
                    var count = 0
                    for item in json.arrayValue
                    {
                        count += 1
                        
                        if item["life"].intValue <= 0
                        {
                            deadCount += 1
                        }
                        else
                        {
                            self.winId = item["user_id"].intValue
                            print("winId",self.winId)
                        }
                        
                        if (count == ShareData.shared.playerNum)
                        {
                            break
                        }
                    }
                    
                    if (deadCount == ShareData.shared.playerNum - 1)
                    {
                        print("ゲーム終了")
                        self.timer?.invalidate()
                        self.performSegue(withIdentifier: "toresult", sender: self)
                        return
                    }

                    // JSON配列の中をループで検索
                    for item in json.arrayValue
                    {
                        // 自分のIDと一致するか確認
                        if item["user_id"].intValue == self.id
                        {
                            if item["life"].doubleValue !=  self.life
                            {
                                self.hpDif = item["life"].doubleValue
                                self.HPset()
                                print("life",self.hpDif)
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
        damageview.frame = self.view.bounds
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        self.view.addSubview(damageview)
        if self.hpDif >= self.life
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
        
        else if hpDif <= self.life
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
        self.life = self.hpDif
        
        let lifePercentage = life / 100.0
        guard let parentView = hpBar.superview,
              let widthConstraint = hpBarWidthConstraint else { return }
        
        widthConstraint.isActive = false
        
        let newWidthConstraint = NSLayoutConstraint(
            item: hpBar!, attribute: .width,
            relatedBy: .equal,
            toItem: parentView, attribute: .width,
            multiplier: 0.935897 * lifePercentage,
            constant: 0
        )
        
        newWidthConstraint.isActive = true
        hpBarWidthConstraint = newWidthConstraint
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        if life <= 0
        {
            pause.isHidden = false
            return
        }
        if life >= 100
        {
            life = 100
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
                    self.targetId = 1
                    self.damage()
                }
                else if nodeName == "player2"
                {
                    self.targetId = 2
                    self.damage()
                }
                else if nodeName == "player3"
                {
                    self.targetId = 3
                    self.damage()
                }
                else if nodeName == "player4"
                {
                    self.targetId = 4
                    self.damage()
                }
                else if nodeName == "items"
                {
                    if itemUse
                    {
                        return
                    }
                    
                    if let randitem = self.items.randomElement(), let plane = hitNode.geometry as? SCNPlane {
                        
                        self.currentItem = self.appearanceItem
                        self.icon.image = UIImage(named: self.itemImageName[self.currentItem.rawValue])
                        self.iconLine.image = UIImage(named: self.itemBackline[self.currentItem.rawValue])
                        
                        self.appearanceItem = randitem
                        plane.firstMaterial?.diffuse.contents = UIImage(named: self.itemImageName[randitem.rawValue])
                        
                    }
                }
            }
        }
    }
    func damage()
    {
        TapticEngine.notification.feedback(.success)
        let url = "https://yusk1450.sakura.ne.jp/barng/damage"

                let parameters:[String: Any] = [
                    "room_id": 1,
                    "my_user_id": self.id,
                    "target_user_id": self.targetId
                ]
        
                Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
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
                                self.winId = item["user_id"].intValue
                                print("winId",self.winId)
                            }
                            
                            if (count == ShareData.shared.playerNum)
                            {
                                break
                            }
                        }
                        
                        if (lifeCount == ShareData.shared.playerNum - 1)
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
                                if item["life"].doubleValue !=  self.life
                                {
                                    self.hpDif = item["life"].doubleValue
                                    self.HPset()
                                    print("life",self.hpDif)
                                    return
                                }

                                break
                            }
                        }
                        
                        
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
        if self.itemUse
        {
            return
        }
        self.itemUse = true
        self.iconBack.frame.size.height = 60
        self.iconBack.frame.origin.y = self.iconBackY
        self.iconLine.image = UIImage(named: "")
        
        

        if currentItem == .Attack
        {
            iconBack.backgroundColor = UIColor.csred
            self.item()
            UIView.animate(withDuration: 5.0, animations: {
                self.iconBack.frame.origin.y += 60.0
                self.iconBack.frame.size.height = 0
            }) { finished in
                if finished
                {
                    self.iconBack.backgroundColor = UIColor.clear
                    self.currentItem = .None
                    self.icon.image = UIImage(named: "item_no_icon")
                    self.itemUse = false
                    self.item()
                    print(self.itemUse)
                    
                }
            }
        }
        else if currentItem == .Guard
        {
            iconBack.backgroundColor = UIColor.csblue
            self.item()
            
            UIView.animate(withDuration: 5.0, animations: {
                self.iconBack.frame.origin.y += 60.0
                self.iconBack.frame.size.height = 0
            }) { finished in
                if finished
                {
                    
                    self.iconBack.backgroundColor = UIColor.clear
                    self.currentItem = .None
                    self.icon.image = UIImage(named: "item_no_icon")
                    self.itemUse = false
                    self.item()
                    print(self.itemUse)
                }
            }
        }
        else if currentItem == .Heal
        {
            recovery()
            self.iconBack.backgroundColor = UIColor.clear
            self.currentItem = .None
            self.icon.image = UIImage(named: "item_no_icon")
            self.itemUse = false

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
