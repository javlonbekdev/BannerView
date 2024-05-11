//
//  AppDelegate.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/13.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

      var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let vc = ViewController()
        window = UIWindow()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        return true
    }


}

