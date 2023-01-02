//
//  CareTeamViewControllerRepresentable.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import CareKit
import SwiftUI
import UIKit

struct CareTeamViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    func updateUIViewController(_ taskViewController: UIViewController, context: Context) {}
    func makeUIViewController(context: Context) -> UIViewController {
        let manager = CKCareKitManager.shared

        let viewController = OCKContactsListViewController(storeManager: manager.synchronizedStoreManager)
        viewController.title = "Care Team"

        return UINavigationController(rootViewController: viewController)
    }
}
