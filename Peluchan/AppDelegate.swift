//
//  AppDelegate.swift
//  Peluchan
//
//  Created by Alejandro Quiroz Carmona on 20/07/25.
//

import UIKit
import SDWebImage
import SDWebImageAVIFCoder
import SDWebImageWebPCoder

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        if #available(iOS 14.0, *) {} else {
            SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
            SDImageCodersManager.shared.addCoder(SDImageAVIFCoder.shared)
        }
        
        return true
    }
}

