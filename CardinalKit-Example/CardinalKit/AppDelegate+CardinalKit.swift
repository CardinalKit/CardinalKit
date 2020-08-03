//
//  AppDelegate+CardinalKit.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import ResearchKit
import Firebase
import CardinalKit

extension AppDelegate {
    
    /**
     Handle special CardinalKit logic for when the app is launched.
    */
    func CKAppLaunch() {
        
        // (1) lock the app and prompt for passcode before continuing
        CKLockApp()
        
        // (2) setup the CardinalKit SDK
        var options = CKAppOptions()
        options.networkDeliveryDelegate = CKAppNetworkManager()
        CKApp.configure(options)
        
        // (3) if we have already logged in
        if CKStudyUser.shared.isLoggedIn {
            CKStudyUser.shared.save()
            
            // (4) then start the requested HK data collection (if any).
            // TODO: make frequency configurable
            let healthStep = CKHealthDataStep(identifier: UUID().uuidString)
            healthStep.getHealthAuthorization { (success, error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
}

// MARK: - Google Identity Integration
extension AppDelegate {
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        /**
         This code runs when a user clicks on a login verification link from an email.
         Uses `Firebase` and the `DynamicLinks` API.
        */
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            
            // (1) check to see if we have a valid login link
            guard let link = dynamiclink?.url?.absoluteString,
                let email = CKStudyUser.shared.email else { // (1.5) and the learner has entered an email
                return
            }
            
            // (2) & if this link is authorized to sign the user in
            if Auth.auth().isSignIn(withEmailLink: link) {
                // (3) process sign-in
                Auth.auth().signIn(withEmail: email, link: link, completion: { (result, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    if let confirmedEmail = result?.user.email {
                        // (4) confirm email and inform app of authorization as needed.
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
        // TODO: handle any source links here if needed
        /*if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            return true
        }*/
        return false
    }
    
}


// MARK: - Passcode Functionality
extension AppDelegate: ORKPasscodeDelegate {
    
    /**
     Blocks the app from use until a validated passcode is entered.
     
     Uses `present()` to trigger an `ORKPasscodeViewController`
    */
    func CKLockApp() {
        //only lock the app if there is a stored passcode and a passcode controller isn't already being shown.
        guard ORKPasscodeViewController.isPasscodeStoredInKeychain() && !(containerViewController?.presentedViewController is ORKPasscodeViewController) else { return }
        
        window?.makeKeyAndVisible()
        
        //TODO: make text and passcodeType (?) configurable
        let config = CKPropertyReader(file: "CKConfiguration")
        
        let passcodeViewController = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: config.read(query: "Passcode On Return Text"), delegate: self)
        containerViewController?.present(passcodeViewController, animated: false, completion: nil)
    }
    
    /**
     Run this code when the application enters the background
     to hide app content from the iOS App Switcher (Privacy/Security).
    */
    func CKLockDidEnterBackground() {
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            // Hide content so it doesn't appear in the app switcher.
            containerViewController?.contentHidden = true
        }
    }
    
    func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        // dismiss passcode prompt screen
        containerViewController?.contentHidden = false
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        // TODO: handle authentication failure
    }
    
}
