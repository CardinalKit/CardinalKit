//
//  ConsentDocument.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Firebase
import ResearchKit

class LoginViewController: ORKLoginStepViewController {
    override func goForward() {
        if let emailRes = result?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer,
           let passwordRes = result?.results?[1] as? ORKTextQuestionResult, let pass = passwordRes.textAnswer {
            let alert = UIAlertController(title: nil, message: "Logging in...", preferredStyle: .alert)

            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)

            taskViewController?.present(alert, animated: false, completion: nil)

            Auth.auth().signIn(withEmail: email, password: pass) { _, error in
                if let error = error {
                    alert.dismiss(animated: false) {
                        let alert = UIAlertController(title: "Login Error!", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                        self.taskViewController?.present(alert, animated: false)
                    }
                } else {
                    alert.dismiss(animated: false, completion: nil)
                    super.goForward()
                }
            }
        }
    }
    
    override func forgotPasswordButtonTapped() {
        let alert = UIAlertController(title: "Reset Password", message: "Enter your email to get a link for password reset.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter your email"
        }

        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            guard let textField = alert.textFields?[0],
                  let email = textField.text else {
                return
            }
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        alert.dismiss(animated: false, completion: nil)
                        if let errCode = AuthErrorCode.Code(rawValue: error._code) {
                            let alert = UIAlertController(
                                title: "Password Reset Error!",
                                message: error.localizedDescription,
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

                            alert.dismiss(animated: false, completion: nil)
                            self.present(alert, animated: false)
                        }
                    } else {
                        print("Email sent!")
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: false)
    }
}
