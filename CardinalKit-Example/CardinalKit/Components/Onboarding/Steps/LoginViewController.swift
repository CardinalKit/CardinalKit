//
//  ConsentDocument.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit
import Firebase

class LoginViewController: ORKLoginStepViewController {
    
    override func forgotPasswordButtonTapped() {
        let config = CKPropertyReader(file: "CKConfiguration")
        
        let alert = UIAlertController(title: "Reset Password", message: "Enter your email to get a link for password reset.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your email"
        }

        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            let textField = alert.textFields![0]
            Auth.auth().sendPasswordReset(withEmail: textField.text!) { error in
                DispatchQueue.main.async {
                    if error != nil {
                        alert.dismiss(animated: true, completion: nil)
                        if let errCode = AuthErrorCode(rawValue: error!._code) {

                            switch errCode {
                                default:
                                    let alert = UIAlertController(title: "Password Reset Error!", message: error?.localizedDescription, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                    
                                    alert.dismiss(animated: true, completion: nil)
                                    self.present(alert, animated: true)
                            }
                        }

                    } else {
                        print("Email sent!")
                    }

                }
            }
        }))
        
//        alert.addAction(UIAlertAction(title: "Email", style: .default, handler: { (action) in
//            let email = config.read(query: "Email")
//                       EmailHelper.shared.sendEmail(subject: "App Support Request", body: "Enter your support request here.", to: email)
//        }))
//
//        alert.addAction(UIAlertAction(title: "Phone", style: .default, handler: { (action) in
//            let phone = config.read(query: "Phone")
//            let telephone = "tel://"
//            let formattedString = telephone + phone
//            guard let url = URL(string: formattedString) else { return }
//            UIApplication.shared.open(url)
//        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
}
