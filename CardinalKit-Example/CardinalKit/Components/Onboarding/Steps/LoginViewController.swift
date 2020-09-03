//
//  ConsentDocument.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

class LoginViewController: ORKLoginStepViewController {
    
    override func forgotPasswordButtonTapped() {
        let config = CKPropertyReader(file: "CKConfiguration")
        
        let alert = UIAlertController(title: "Please contact the developer.", message: "Would you like to call or email them?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Email", style: .default, handler: { (action) in
            let email = config.read(query: "Email")
                       EmailHelper.shared.sendEmail(subject: "App Support Request", body: "Enter your support request here.", to: email)
        }))
        
        alert.addAction(UIAlertAction(title: "Phone", style: .default, handler: { (action) in
            let phone = config.read(query: "Phone")
            let telephone = "tel://"
            let formattedString = telephone + phone
            guard let url = URL(string: formattedString) else { return }
            UIApplication.shared.open(url)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
}
