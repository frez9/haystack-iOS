//
//  AppDelegate.swift
//  Haystack
//
//  Created by Frezghi Noel on 8/1/2020.
//  Copyright © 2020 Haystack. All rights reserved.
//

import UIKit
import SCSDKLoginKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        SCSDKLoginClient.refreshAccessToken { auth, error in }

        if SCSDKLoginClient.isUserLoggedIn {
            if defaults.bool(forKey: "user_did_login") == true {
                let viewController = HomeViewController()
                window.rootViewController = UINavigationController(rootViewController: viewController)
                self.window = window
                window.makeKeyAndVisible()

            } else {

                let viewController = LoginViewController()
                window.rootViewController = UINavigationController(rootViewController: viewController)
                self.window = window
                window.makeKeyAndVisible()

            }

        } else {
            let viewController = LoginViewController()
            window.rootViewController = UINavigationController(rootViewController: viewController)
            self.window = window
            window.makeKeyAndVisible()

        }

        FirebaseApp.configure()

        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return SCSDKLoginClient.application(app, open: url, options: options)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
}
