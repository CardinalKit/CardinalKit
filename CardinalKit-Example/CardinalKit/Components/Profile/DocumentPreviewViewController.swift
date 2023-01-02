//
//  DocumentPreviewViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import SwiftUI
import UIKit


struct DocumentPreviewViewController: UIViewControllerRepresentable {
    private var isActive: Binding<Bool>
    private let viewController = UIViewController()
    private var docController: UIDocumentInteractionController?

    init(_ isActive: Binding<Bool>, url: URL?) {
        self.isActive = isActive
        if let url = url {
            self.docController = UIDocumentInteractionController(url: url)
        }
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<DocumentPreviewViewController>
    ) -> UIViewController {
        viewController
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<DocumentPreviewViewController>
    ) {
        if self.isActive.wrappedValue && docController?.delegate == nil { // to not show twice
            self.docController?.delegate = context.coordinator
            self.docController?.presentPreview(animated: false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }

    final class Coordinator: NSObject, UIDocumentInteractionControllerDelegate { // works as delegate
        let owner: DocumentPreviewViewController
        init(owner: DocumentPreviewViewController) {
            self.owner = owner
        }
        func documentInteractionControllerViewControllerForPreview(
            _ controller: UIDocumentInteractionController
        ) -> UIViewController {
            owner.viewController
        }

        func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
            controller.delegate = nil // done, so unlink self
            owner.isActive.wrappedValue = false // notify external about done
        }
    }
}
