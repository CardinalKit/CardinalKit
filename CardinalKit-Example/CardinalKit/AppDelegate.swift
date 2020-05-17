//
//  AppDelegate.swift
//  Master-Sample
//
//  Created by Santiago Gutierrez on 9/22/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit
import Firebase
import ResearchKit
import CardinalKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var containerViewController: LaunchContainerViewController? {
        return window?.rootViewController as? LaunchContainerViewController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        lockApp()
        
        FirebaseApp.configure()
        
        if StudyUser.shared.currentUser != nil {
            StudyUser.shared.save() // TODO: for testing, keep updating user record
            CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .hourly)
        }
        
        if !UserDefaults.standard.bool(forKey: Constants.prefFirstRunWasMarked) {
            if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
                ORKPasscodeViewController.removePasscodeFromKeychain()
            }
            try? Auth.auth().signOut()
            UserDefaults.standard.set(true, forKey: Constants.prefFirstRunWasMarked)
        }
    
        CKApp.configure()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            // Hide content so it doesn't appear in the app switcher.
            containerViewController?.contentHidden = true
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        lockApp()
    }
    
}

// MARK - HELPER: Google Identity
extension AppDelegate {
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            
            guard let link = dynamiclink?.url?.absoluteString, let email = StudyUser.globalEmail() else {
                return
            }
            
            if Auth.auth().isSignIn(withEmailLink: link) {
                Auth.auth().signIn(withEmail: email, link: link, completion: { (result, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    if let confirmedEmail = result?.user.email {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.notificationUserLogin), object: confirmedEmail)
                        UserDefaults.standard.set(true, forKey: Constants.prefConfirmedLogin)
                    }
                    
                })
            }
        }
        
        return handled
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                           annotation: "")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        /*if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            print("handled source link")
            return true
        }*/
        return false
    }
    
}


// MARK - HELPER: Passcode Functionality
extension AppDelegate: ORKPasscodeDelegate {
    
    func lockApp() {
        /*
         Only lock the app if there is a stored passcode and a passcode
         controller isn't already being shown.
         */
        guard ORKPasscodeViewController.isPasscodeStoredInKeychain() && !(containerViewController?.presentedViewController is ORKPasscodeViewController) else { return }
        
        window?.makeKeyAndVisible()
        
        let passcodeViewController = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: "Welcome back!", delegate: self)
        containerViewController?.present(passcodeViewController, animated: false, completion: nil)
    }
    
    func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        containerViewController?.contentHidden = false
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        
    }
    
}
