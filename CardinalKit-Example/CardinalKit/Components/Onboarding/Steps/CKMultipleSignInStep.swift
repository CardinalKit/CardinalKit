//
//  CKMultipleSignInStep.swift
//
//  Created for the CardinalKit framework.
//  Copyright © 2021 CardinalKit. All rights reserved.
//

import AuthenticationServices
import CardinalKit
import CryptoKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import ResearchKit
import SwiftUI

public class CKMultipleSignInStep: ORKQuestionStep {
    override public init(identifier: String) {
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
        step as? CKMultipleSignInStep
    }

    fileprivate var currentNonce: String?

    lazy var content = UIHostingController(
        rootView: CKSignInView(
            googleSignInAction: googleSignInAction,
            appleSignInAction: appleSignInAction,
            emailSignInAction: emailSignInAction
        )
    )
    
    override public func viewDidLoad() {
        addChild(content)
        view.addSubview(content.view)

        content.view.translatesAutoresizingMaskIntoConstraints = false
        content.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        content.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        content.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    func emailSignInAction() {
        self.setAnswer(true)
        super.goForward()
    }

    func appleSignInAction() {
        currentNonce = .makeRandomNonce()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = currentNonce?.sha256

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            self.showError(message: "Unable to obtain AppleID credentials")
            return
        }
        guard let nonce = currentNonce else {
            self.showError(message: "Invalid state: A login callback was received, but no login request was sent.")
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            self.showError(message: "Unable to fetch identity token")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            self.showError(message: "Unable to serialize token string from data")
            return
        }

        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )

        Auth.auth().signIn(with: credential) { _, error in
            if let error = error {
                self.showError(error)
            } else {
                self.setAnswer(false)
                super.goForward()
            }
        }
    }

    func googleSignInAction() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }

        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if let error = error {
                self.showError(error)
                return
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: authentication.accessToken
            )
            
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    self.showError(error)
                } else {
                    self.setAnswer(false)
                    super.goForward()
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        Alerts.showInfo(
            title: "Error signing in: \(error)",
            message: error.localizedDescription
        )
    }

    private func showError(title: String = "Error", message: String) {
        Alerts.showInfo(
            title: title,
            message: message
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
