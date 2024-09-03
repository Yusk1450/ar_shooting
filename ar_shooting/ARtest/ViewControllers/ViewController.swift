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

class ViewController: UIViewController, ARSCNViewDelegate,UIGestureRecognizerDelegate {

    let HP = [-1,-1,-1,-1]
    
    @IBOutlet var sceneView: ARSCNView!
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
 
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
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // if the anchor is not of type ARImageAnchor (which means image is not detected), just return
        guard let imageAnchor = anchor as? ARImageAnchor else {return}
        
        //コンテンツ表示
        let imageName = imageAnchor.referenceImage.name

         
        // 検出された画像の物理サイズに合わせて平面を作成
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIImage(named: "barng_target")
    
                
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -Float.pi / 2
                
            // 画像に関連付けられたノードに名前を設定
            planeNode.name = imageName
            node.addChildNode(planeNode)

        
    }
    
    @objc func tap(_ tapRecognizer: UITapGestureRecognizer) {
        let touchLocation = tapRecognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touchLocation, options: nil)
        
        if let hitNode = hitTestResults.first?.node {
            // ノードの名前を確認して、対応する処理を実行
            if let nodeName = hitNode.name {
                if nodeName == "player1" {
                    print("tap1")
                } else if nodeName == "player2" {
                    print("tap2")
                }else if nodeName == "player3" {
                    print("tap3")
                }
                else if nodeName == "player4" {
                    print("tap4")
                }
            }
        }
    }
}
