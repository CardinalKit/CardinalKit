//
//  SceneDelegate.swift
//  funwithswiftui
//
//  Created by Varun Shenoy on 8/8/20.
//  Copyright © 2020 Varun Shenoy. All rights reserved.
//

import SwiftUI
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = LaunchUIView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return false
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            
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
                        print("confirmed!")
                    }
                    
                })
            }
        }
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        CKLockApp()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        CKLockDidEnterBackground()
    }


}

