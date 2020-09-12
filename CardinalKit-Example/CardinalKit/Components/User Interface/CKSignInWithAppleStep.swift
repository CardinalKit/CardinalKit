//
//  CKSignInWithAppleStep.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import ResearchKit
import CryptoKit
import FirebaseAuth
import AuthenticationServices
import CardinalKit

/// https://developer.apple.com/sign-in-with-apple/
class CKSignInWithAppleStep: ORKInstructionStep {
    override init(identifier: String) {
        super.init(identifier: identifier)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        // let config = CKPropertyReader(file: "CKConfiguration")
        // title = config.read(query: "Sign-in with Apple Title")
        // text = config.read(query: "Sign-in with Apple Text")
        title = NSLocalizedString("Sign-in with Apple", comment: "")
        text = NSLocalizedString("The fast, easy way to sign in. All accounts are protected with two-factor authentication for superior security, and Apple will not track your activity in your app or website.", comment: "")
    }
}

class CKSignInWithAppleStepViewController: ORKInstructionStepViewController, ASAuthorizationControllerDelegate {
    var signInWithAppleStep: CKSignInWithAppleStep? {
        return step as? CKSignInWithAppleStep
    }

    /// Unhashed nonce.
    fileprivate var currentNonce: String!

    override func goForward() {
        currentNonce = .makeRandomNonce()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = currentNonce.sha256

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
            guard let error = error else {
                // User is signed in to Firebase with Apple.
                super.goForward()
                return
            }
            // Error. If error.code == .MissingOrInvalidNonce, make sure
            // you're sending the SHA256-hashed nonce as a hex string with
            // your request to Apple.
            print("Sign in with Apple errored: \(error)")
            Alerts.showInfo(title: "Failed to Sign in with Apple", message: error.localizedDescription)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        Alerts.showInfo(title: "Failed to Sign in with Apple", message: error.localizedDescription)
    }
}

extension String {
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

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
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
