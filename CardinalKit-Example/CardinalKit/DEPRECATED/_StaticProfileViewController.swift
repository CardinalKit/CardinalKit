//
//  StaticProfileViewController.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit
import MessageUI
import CardinalKit
import ResearchKit

class StaticProfileViewController: UITableViewController {
    
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = CKStudyUser.shared.currentUser {
            self.userIdLabel.text = currentUser.uid
        }
        
        if let release = Bundle.main.releaseVersionNumber,
            let build = Bundle.main.buildVersionNumber {
            let buildDetails = "v\(release) (build \(build))"
            appVersionLabel.text = buildDetails
        }
    }
    
}

extension StaticProfileViewController {
    
    func toWithdraw() {
        performSegue(withIdentifier: "unwindToWithdrawal", sender: nil)
    }
    
}

extension StaticProfileViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let profileItem = ProfileTableItem.profileItem(forSection: indexPath.section, row: indexPath.row)
        
        switch profileItem {
        case .changePasscode:
            editPasscode()
        case .help:
            break
        case .contactEmail:
            sendEmail()
        case .contactPhone:
            callPhone()
        case .withdraw:
            toWithdraw()
        }
    }
    
}

//MARK: Call Support Phone
extension StaticProfileViewController {
    func callPhone() {
        guard let number = URL(string: "tel://1234567890") else { return }
        UIApplication.shared.open(number)
    }
}

//MARK: Send Support Email
extension StaticProfileViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.mailComposeDelegate = nil
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendEmail() {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients(["contact@domain.com"])
        mailComposeViewController.setSubject("Support Request")
        mailComposeViewController.setMessageBody("Enter your support request here.", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Could Not Send Email", message: "Looks like you don't have Mail app setup. Please configure to share via email.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension StaticProfileViewController : ORKPasscodeDelegate {
    
    func editPasscode() {
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewController(withText: "", delegate: self, passcodeType:.type4Digit)
            present(editPasscodeViewController, animated: true, completion: nil)
        }
    }
    
    func passcodeViewControllerDidCancel(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
        
        let alert = UIAlertController(title: "Wrong Passcode Entered", message:"", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
