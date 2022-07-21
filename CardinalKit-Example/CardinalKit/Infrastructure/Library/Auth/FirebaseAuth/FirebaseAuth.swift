//
//  FirebaseAuth.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 28/06/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class FirebaseAuth: NSObject, AuthLibrary,ASAuthorizationControllerDelegate {
    var user:User?
    
    override init() {
        super.init()
        if let user = Auth.auth().currentUser {
            self.user = User(uid: user.uid, email: user.email)
        }
        Auth.auth().addStateDidChangeListener() { auth, user in
            if (user != nil){
                self.user = User(uid: user!.uid, email: user!.email)
            }
            NotificationCenter.default.post(name: .onUserStateChange, object: user != nil)
        }
    }
    
    func logout(onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void)  {
        do{
            try Auth.auth().signOut()
        }
        catch{
            onError(error)
        }
        onSuccess()
    }
    
    func ResetPassword(email:String,onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                onError(error!)
            }
            else{
                onSuccess()
            }
        }
    }
    
    func LoginIWithUserPass(email:String, pass:String, onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void){
        Auth.auth().signIn(withEmail: email, password: pass) { (res, error) in
            if let error = error {
                onError(error)
            } else {
                onSuccess()
            }
        }
    }
    
    func LoginWithFacebook(onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void, viewController: UIViewController) {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: viewController){ (result, error) -> Void in
            if (error == nil){
              let fbloginresult : LoginManagerLoginResult = result!
              if (result?.isCancelled)!{ return }
              if(fbloginresult.grantedPermissions.contains("email"))
              {
                  let credential = FacebookAuthProvider
                    .credential(withAccessToken: AccessToken.current!.tokenString)
                  Auth.auth().signIn(with: credential) { (authResult, error) in
                      if let error = error {
                          onError (error)
                      } else {
                          onSuccess()
                      }
                  }
              }
            }
        }
    }
    
    private var currentNonce: String!
    
    func LoginWithGoogle(onSuccess:@escaping () -> Void, onError:@escaping (Error) -> Void, viewController:UIViewController) {
        /// Load Web view for sign in process
        //GIDSignIn.sharedInstance()?.signIn()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        
        // Start sign in flow
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController){ user, error in
            if let error = error {
                onError(error)
                return
            }
        
        guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    onError(error)
                }
                else {
                    onSuccess()
                }
            }
        }
    }
    
    private var onAppleError : ((Error) -> Void)?
    private var onAppleSuccess : (() -> Void)?
    
    func LoginWithApple(onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void)  {
        self.onAppleError = onError
        self.onAppleSuccess = onSuccess
        currentNonce = .makeRandomNonce()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = currentNonce.sha256

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    public func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Unable to obtain AppleID credentials")
            return
        }
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.onAppleError?(error)
            } else {
                self.onAppleSuccess?()
            }
        }
    }
    
    public func RegisterUser(email:String, pass:String, onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void){
        Auth.auth().createUser(withEmail: email, password: pass) { (res, error) in
            DispatchQueue.main.async {
                if error != nil {
                    onError(error!)
                    
                } else {
                    onSuccess()                }
            }
        }
    }
    
    func AuthDinamycLink(url: URL){
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
        
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
    
    
}

fileprivate extension String {
    var sha256: String {
        return SHA256.hash(data: Data(utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }

    /// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    static func makeRandomNonce(ofLength length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            for random in randoms {
                if remainingLength == 0 {
                    break
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}


