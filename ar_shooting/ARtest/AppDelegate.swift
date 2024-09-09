//
//  AppDelegate.swift
//  ARtest
//
//  Created by ichinose-PC on 2024/05/17.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let screenWidth = UIScreen.main.bounds.size.width
        let storyboard: UIStoryboard

        if screenWidth == 896.0 {
            storyboard = UIStoryboard(name: "Main_iphone11", bundle: nil)
            
            // 初期ViewControllerを取得し、rootViewControllerに設定
            if let initialViewController = storyboard.instantiateInitialViewController() {
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }else if screenWidth == 844.0 {
            storyboard = UIStoryboard(name: "Main_iphone12", bundle: nil)
            
            // 初期ViewControllerを取得し、rootViewControllerに設定
            if let initialViewController = storyboard.instantiateInitialViewController() {
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle




}

