//
//  CKSignInWithAppleStep.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import ResearchKit
import CardinalKit
import CryptoKit
import FirebaseAuth
import AuthenticationServices

/// A step that presents information about and performes
/// [Sign in with Apple](https://developer.apple.com/sign-in-with-apple/).
///
/// ```
/// // Initates the Sign in with Apple step:
/// let signInWithAppleStep = CKSignInWithAppleStep(identifier: "SignInApple")
/// // Adds the above step (with all other steps) into a task:
/// let orderedTask = ORKOrderedTask(identifier: "StudyOnboardingTask", steps: [
///     signInWithAppleStep, ...
/// ])
///
/// // Then, in the delegate for the task view controller presenting such task:
/// func taskViewController(_ taskViewController: ORKTaskViewController,
///                         viewControllerFor step: ORKStep) -> ORKStepViewController? {
///     // Use the correct view controller for this step.
///     if step is CKSignInWithAppleStep {
///         return CKSignInWithAppleStepViewController(step: step)
///     }
///     ...
/// }
///
/// // That's it!
/// ```
///
/// Additionally, you can direct the user to learn more about Sign in with Apple:
///
/// ```
/// func taskViewController(_ taskViewController: ORKTaskViewController,
///                         hasLearnMoreFor step: ORKStep) -> Bool {
///     // Indicates the step should display learn more button.
///     if step is CKSignInWithAppleStep {
///         return true
///     }
///     ...
/// }
///
///
/// func taskViewController(_ taskViewController: ORKTaskViewController,
///                         learnMoreForStep stepViewController: ORKStepViewController) {
///     // Presents the "How to use Sign in with Apple" guide.
///     if stepViewController is CKSignInWithAppleStepViewController {
///         UIApplication.shared.open(URL(string: "https://support.apple.com/HT210318")!)
///     }
///     ...
/// }
/// ```
///
/// - Requires: View controller for this step is `CKSignInWithAppleStepViewController`.
/// - Important: Though you don't have to write any code, you do need to setup Firebase and Xcode project
/// following the [Firebase setup tutorial](https://firebase.google.com/docs/auth/ios/apple)
/// - Note: [How to use Sign in with Apple](https://support.apple.com/HT210318) might be useful
/// as the "Learn More" destination for this step.
public class CKSignInWithAppleStep: ORKInstructionStep {
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
        let config = CKPropertyReader(file: "CKConfiguration")
        self.requestedScopes = requestedScopes
        super.init(identifier: identifier)
        self.title = title ?? config["Login-Sign-In-With-Apple"]["Title"] as! String
        self.text = text ?? config["Login-Sign-In-With-Apple"]["Text"] as! String
    }

    @available(*, unavailable)
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class CKSignInWithAppleStepViewController: ORKInstructionStepViewController,
                                                  ASAuthorizationControllerDelegate {
    /// The step presented by the step view controller.
    public var signInWithAppleStep: CKSignInWithAppleStep! {
        return step as? CKSignInWithAppleStep
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        continueButtonTitle = NSLocalizedString(
            " Sign in with Apple",
            comment: "Please use Apple's official translations"
        )
    }

    /// Unhashed nonce.
    private var currentNonce: String!

    /// Initiates Sign in / up with Apple attempt.
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
