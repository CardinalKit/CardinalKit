//
//  PasscodeViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SwiftUI
import ResearchKit
import CardinalKit

struct PasscodeViewController: UIViewControllerRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    } 

    typealias UIViewControllerType = ORKPasscodeViewController
    
    func updateUIViewController(_ uiViewController: ORKPasscodeViewController, context: Context) {}
    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {}
    func makeUIViewController(context: Context) -> ORKPasscodeViewController {
        let config = CKPropertyReader(file: "CKConfiguration")
        
        let num = config.read(query: "Passcode Type")
        
        if num == "4" {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewController(withText: "", delegate: context.coordinator, passcodeType:.type4Digit)
            
            return editPasscodeViewController
        } else {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewController(withText: "", delegate: context.coordinator, passcodeType: .type6Digit)
            
            return editPasscodeViewController
        }
    }

    class Coordinator: NSObject, ORKPasscodeDelegate {
        func passcodeViewControllerDidCancel(_ viewController: UIViewController) {
            viewController.dismiss(animated: false, completion: nil)
        }
        
        func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
            viewController.dismiss(animated: false, completion: nil)
        }
        
        func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
            viewController.dismiss(animated: false, completion: nil)
            
            Alerts.showInfo(title: "Wrong passcode entered", message: "Okay")
        }
    }
    
}
