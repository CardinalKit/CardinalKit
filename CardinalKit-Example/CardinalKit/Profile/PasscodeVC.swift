//
//  PasscodeVC.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/11/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import ResearchKit

struct PasscodeVC: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: ORKPasscodeViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @EnvironmentObject var config: CKPropertyReader

    func makeUIViewController(context: Context) -> ORKPasscodeViewController {
        let num = config.read(query: "Passcode Type")

        let passcodeType: ORKPasscodeType = num == "6" ? .type6Digit : .type4Digit
        let editPasscodeViewController = ORKPasscodeViewController
            .passcodeEditingViewController(withText: "",
                                           delegate: context.coordinator,
                                           passcodeType: passcodeType)
        return editPasscodeViewController
    }

    class Coordinator: NSObject, ORKPasscodeDelegate {
        func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }

        func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}

struct PasscodeVC_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeVC()
    }
}
