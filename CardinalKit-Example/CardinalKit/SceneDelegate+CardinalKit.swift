//
//  SceneDelegate+CardinalKit.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/13/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import ResearchKit
import SwiftUI

// Extensions add new functionality to an existing class, structure, enumeration, or protocol type.
// https://docs.swift.org/swift-book/LanguageGuide/Extensions.html
extension SceneDelegate: ORKPasscodeDelegate {
    /**
     Hide content so it doesn't appear in the app switcher.
    */
    func toggleContainer(hidden: Bool) {
        if let isViewLoaded = window?.rootViewController?.isViewLoaded, isViewLoaded {
            window?.rootViewController?.view.isHidden = hidden
        }
    }
    
    /**
     Blocks the app from use until a validated passcode is entered.
     
     Uses `present()` to trigger an `ORKPasscodeViewController`
    */
    func CKLockApp() {
        // Only lock the app if there is a stored passcode and a passcode controller isn't already being shown.
        guard ORKPasscodeViewController.isPasscodeStoredInKeychain()
                && !(window?.rootViewController?.presentedViewController is ORKPasscodeViewController) else {
            return
        }
        
        window?.makeKeyAndVisible()

        let config = CKPropertyReader(file: "CKConfiguration")
        
        let passcodeViewController = ORKPasscodeViewController.passcodeAuthenticationViewController(
            withText: config.read(query: "Passcode On Return Text"),
            delegate: self
        )
        passcodeViewController.isModalInPresentation = true
        
        window?.rootViewController?.present(passcodeViewController, animated: false, completion: nil)
    }
    
    /**
     Run this code when the application enters the background
     to hide app content from the iOS App Switcher (Privacy/Security).
    */
    func CKLockDidEnterBackground() {
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            toggleContainer(hidden: true)
        }
    }
    
    func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        // dismiss passcode prompt screen
        toggleContainer(hidden: false)
        viewController.dismiss(animated: false, completion: nil)
    }
    
    func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        // Not implemented
    }
}
