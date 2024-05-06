//
//  AppDelegate.swift
//  SecureDefaults
//
//  Created by Victor Peschenkov on 03/16/2019.
//  Copyright (c) 2019 Victor Peschenkov. All rights reserved.
//

import UIKit
import SecureDefaults

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // To get some security in your app just replace `NSUserDefaults` by `SecureDefaults` and set a password 😎.
        let defaults = SecureDefaults()
        if !defaults.isKeyCreated {
            defaults.password = UUID().uuidString
        }
        defaults.set("Thank you for using SecureDefaults!", forKey: "secure.greeting")
        defaults.synchronize()
        
        if let greeting = defaults.string(forKey: "secure.greeting") {
            print("\(greeting)")
        } else {
            print("Ooops... Something is definitely wrong... Let me know about this issue, please!")
        }
        return true
    }
}
