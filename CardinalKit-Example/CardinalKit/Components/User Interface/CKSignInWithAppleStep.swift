//
//  CKSignInWithAppleStep.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import ResearchKit
import CardinalKit
import CryptoKit
import FirebaseAuth
import AuthenticationServices

extension CKPropertyReader {
    public static let `default` = CKPropertyReader(file: "CKConfiguration")
}

/// https://developer.apple.com/sign-in-with-apple/
public class CKSignInWithAppleStep: ORKInstructionStep {
    public var requestedScopes: [ASAuthorization.Scope]

    public init(identifier: String,
         title: String = CKPropertyReader.default.read(query: "Sign-in with Apple Title"),
         text: String? = CKPropertyReader.default.read(query: "Sign-in with Apple Text"),
         requestedScopes: [ASAuthorization.Scope] = [.email]) {
        self.requestedScopes = requestedScopes
        super.init(identifier: identifier)
        self.title = title
        self.text = text
    }

    @available(*, unavailable)
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class CKSignInWithAppleStepViewController: ORKInstructionStepViewController,
                                                  ASAuthorizationControllerDelegate {
    public var signInWithAppleStep: CKSignInWithAppleStep! {
        return step as? CKSignInWithAppleStep
    }

    /// Unhashed nonce.
    private var currentNonce: String!

    public override func goForward() {
        currentNonce = .makeRandomNonce()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = signInWithAppleStep?.requestedScopes ?? [.email]
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
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.showError(error)
            } else {
                // User is signed in to Firebase with Apple.
                super.goForward()
            }
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showError(error)
    }

    /// Handle error.
    private func showError(_ error: Error) {
        // If error.code == .missingOrInvalidNonce,
        // make sure you're sending the SHA256-hashed nonce as a hex string
        // with your request to Apple.
        print("Sign in with Apple errored: \(error)")
        Alerts.showInfo(
            title: NSLocalizedString("Failed to Sign in with Apple", comment: ""),
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
