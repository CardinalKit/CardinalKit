//
//  CKMultipleSignInStep.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 25/11/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import ResearchKit
import CardinalKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FBSDKLoginKit
import SwiftUI

public class CKMultipleSignInStep: ORKQuestionStep {
    public override init(identifier: String) {
        super.init(identifier: identifier)
        self.answerFormat = ORKAnswerFormat.booleanAnswerFormat()
    }

    @available(*, unavailable)
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class CKMultipleSignInStepViewController: ORKQuestionStepViewController, ASAuthorizationControllerDelegate {
    public var CKMultipleSignInStep: CKMultipleSignInStep! {
        return step as? CKMultipleSignInStep
    }
    
    public override func viewDidLoad() {

        let config = CKPropertyReader(file: "CKConfiguration")

        let signInLabel = getSignInLabel(text: config["Sign In Screen"]["Label Text"] as? String ?? "Sign In",
                                         fontSize: config["Sign In Screen"]["Label Font Size"] as? CGFloat ?? 35)
        self.view.addSubview(signInLabel)

        var button: UIButton? = nil
        if config["Login-Sign-In-With-UserPassword"]["Enabled"] as? Bool == true {
            let buttonEmailPassword = getSignInButton(title: "Sign in with Email and Password",
                                                   backgroundColor: .white,
                                                   textColor: .black,
                                                   borderColor: .black,
                                                   reference: button,
                                                   action: #selector(loginEmailAndPasswordAction))
            self.view.addSubview(buttonEmailPassword)
            button = buttonEmailPassword
            
        }
        
        if config["Login-Sign-In-With-Facebook"]["Enabled"] as? Bool == true {
            let buttonFacebook = getSignInButton(title: "Sign in with Facebook",
                                              backgroundColor: UIColor(red: 59, green: 89, blue: 152),
                                              textColor: .white,
                                              borderColor: nil,
                                              reference: button,
                                              action: #selector(loginFacebookAction),
                                              icon: "facebook",
                                              imageOffset: 35)
            self.view.addSubview(buttonFacebook)
            button = buttonFacebook
        }
        
        if config["Login-Sign-In-With-Google"]["Enabled"] as? Bool == true {
            let buttonGoogle = getSignInButton(title: "Sign in with Google",
                                            backgroundColor: .white,
                                            textColor: .gray,
                                            borderColor: UIColor(red: 66, green: 133, blue: 244),
                                            reference: button,
                                            action: #selector(loginGoogleAction),
                                            icon: "google")
            self.view.addSubview(buttonGoogle)
            button = buttonGoogle
        }
        
        if config["Login-Sign-In-With-Apple"]["Enabled"] as? Bool == true {
            let buttonApple = getSignInButton(title: "Sign in with Apple",
                                           backgroundColor: .black,
                                           textColor: .white,
                                           borderColor: nil,
                                           reference: button,
                                           action: #selector(loginAppleAction),
                                           icon: "apple")
            self.view.addSubview(buttonApple)
            button = buttonApple
        }
        
        self.view.backgroundColor = .white
    }



    func getSignInLabel(text: String, fontSize: CGFloat = 35) -> UILabel {
        let signInLabel = UILabel(frame: CGRect(x: 0, y: 100, width: 450, height: 50))
        signInLabel.center.x = view.center.x
        signInLabel.text = text
        signInLabel.font = signInLabel.font.withSize(fontSize)
        signInLabel.textAlignment = NSTextAlignment.center
        return signInLabel
    }

    func getSignInButton(
        title: String,
        backgroundColor: UIColor,
        textColor: UIColor,
        borderColor: UIColor?,
        reference: UIButton?,
        action: Selector,
        icon image: String = "",
        imageOffset: CGFloat = 50
    ) -> UIButton {
        let button = UIButton(frame: CGRect(x: 200, y: 200, width: 350, height: 50))
        button.center = view.center

        if let reference = reference {
            button.center.y = reference.center.y - 60
        } else{
            button.center.y = CGFloat(Float(view.frame.maxY) - 200)
        }

        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.addTarget(self, action: action,for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.backgroundColor = backgroundColor

        if let borderColor = borderColor {
            button.layer.borderWidth = 2
            button.layer.borderColor =  borderColor.cgColor
        }

        if(image != "") {
            button.setImage(UIImage(named: image)!, for: .normal)
            button.imageEdgeInsets.left = -imageOffset
        }

        return button
    }
    
    @objc
    func loginEmailAndPasswordAction() {
        self.setAnswer(true)
        super.goForward()
    }
    
    @objc
    func loginFacebookAction(sender: AnyObject) {//action of the custom button in the storyboard
        let fbLoginManager: LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self){ (result, error) -> Void in
            if (error == nil){
                let fbloginresult: LoginManagerLoginResult = result!
                if (result?.isCancelled)!{ return }

                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                    Auth.auth().signIn(with: credential) { (_, error) in
                        if let error = error {
                            self.showError(error)
                        } else {
                            self.setAnswer(false)
                            super.goForward()
                        }
                    }
                }
            }
        }
    }
    
    private var currentNonce: String!
    
    @objc
    func loginAppleAction() {
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

        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.showError(error)
            } else {
                self.setAnswer(false)
                super.goForward()
            }
        }
    }
    
    @objc
    func loginGoogleAction(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: self){ user, error in
            if let error = error {
                self.showError(error)
                return
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.showError(error)
                }
                else {
                    self.setAnswer(false)
                    super.goForward()
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        print("Error signing in: \(error)")
        Alerts.showInfo(
            title: NSLocalizedString("Error signing in: \(error)", comment: ""),
            message: error.localizedDescription
        )
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
