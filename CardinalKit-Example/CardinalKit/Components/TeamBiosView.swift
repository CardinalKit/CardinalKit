//
//  ContentView.swift
//  Assignment One
//

import SwiftUI
import UIKit
import CareKit

struct TeamBiosView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIViewController
    
    func updateUIViewController(_ taskViewController: UIViewController, context: Context) {}
    func makeUIViewController(context: Context) -> UIViewController {
        let manager = CKCareKitManager.shared
        let vc = OCKContactsListViewController(storeManager: manager.synchronizedStoreManager)
        return UINavigationController(rootViewController: vc)
    }
    
}
