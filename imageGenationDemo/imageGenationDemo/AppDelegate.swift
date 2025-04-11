//
//  AppDelegate.swift
//  imageGenationDemo
//
//  Created by Harsh on 26/11/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ViewController.rootVC(storyboard: UIStoryboard(name: "Main", bundle: nil))
        
        
        return true
    }
    
    static func getAppDelegateRef() -> Self?{
        return UIApplication.shared.delegate as? Self
    }
    
    func getActiveVC() -> UIViewController?{
        guard let vc = (self.window?.rootViewController as? UINavigationController)?.viewControllers.last else{
            print("Not found the root view controller as? UIViewController in ",#function)
            return nil
        }
        return vc
    }   // getActiveVC
    
    func setRootViewController(initialViewController: UIViewController) {
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
        }
        let nav1 = UINavigationController()
        nav1.viewControllers = [initialViewController]
        nav1.isNavigationBarHidden = true
        nav1.interactivePopGestureRecognizer?.isEnabled = false
        nav1.navigationBar.isHidden = true
        self.window?.rootViewController = nav1
        self.window?.makeKeyAndVisible()
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
    }



}

