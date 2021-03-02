//
//  SignInWithEmailAuth.swift
//  CardinalKit_Example
//
//  Created by Harry Mellsop on 3/2/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import ResearchKit
import CardinalKit
import CryptoKit
import FirebaseAuth
import AuthenticationServices

public class SignInWithEmailStep: ORKInstructionStep {
    /// The contact information to be requested from the user during authentication.
    public var requestedScopes: [ASAuthorization.Scope]

    /// Returns a new step initialized with the specified parameters.
    ///
    /// - Parameters:
    ///   - identifier: The unique identifier of the step.
    ///   - title: The primary text to display for the step in a localized string.
    ///   Defaults to the value of "Sign in with Apple Title" entry from `CKConfiguration.plist`.
    ///   - text: Additional text to display for the step in a localized string.
    ///   Defaults to the value of "Sign in with Apple Text" entry from `CKConfiguration.plist`.
    ///   - requestedScopes: The contact information to be requested from the user during authentication.
    ///   Defaults to email only.
    public init(identifier: String,
         title: String! = nil,
         text: String! = nil,
         requestedScopes: [ASAuthorization.Scope] = [.email]) {
        self.requestedScopes = requestedScopes
        super.init(identifier: identifier)
        self.title = "Sign in"
        self.text = "Continuing will sign you in using the credentials from the email sent by your provider"
    }

    @available(*, unavailable)
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class SignInWithEmailStepController: ORKInstructionStepViewController {
    /// The step presented by the step view controller.
    public var signInWithEmailStep: SignInWithEmailStep! {
        return step as? SignInWithEmailStep
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        continueButtonTitle = NSLocalizedString(
            "Sign in with email credentials",
            comment: "Please use Apple's official translations"
        )
    }

    public override func goForward() {
        
        // (2) & if this link is authorized to sign the user in
        print("WE ARE NOW CHECKING THE DYNAMIC LINK")
        if Auth.auth().isSignIn(withEmailLink: dynamicLinkLogin.link) {
            print("WE HAVE A VALID SIGN IN LINK")
            // (3) process sign-in
            Auth.auth().signIn(withEmail: dynamicLinkLogin.email, link: dynamicLinkLogin.link, completion: { (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.showError(error)
                }
                
                if let confirmedEmail = result?.user.email {
                    // (4) confirm email and inform app of authorization as needed.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.notificationUserLogin), object: confirmedEmail)
                    UserDefaults.standard.set(true, forKey: Constants.prefConfirmedLogin)
                    print("confirmed!")
                    super.goForward()
                }
                
            })
        } else {
            print("THE LINK IS INVALID")
        }
        
    }

    /// Handle error.
    private func showError(_ error: Error) {
        // If error.code == .missingOrInvalidNonce,
        // make sure you're sending the SHA256-hashed nonce as a hex string
        // with your request to Apple.
        print("Sign in with Apple errored: \(error)")
        Alerts.showInfo(
            title: NSLocalizedString("Failed to Sign in", comment: ""),
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
