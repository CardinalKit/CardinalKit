//
//  DocumentView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import Firebase
import SwiftUI

struct DocumentView: View {
    @State private var showPreview = false
    @State var documentsURL: URL?
    
    var body: some View {
        HStack {
            Text("View Consent Document")
            Spacer()
            Text("›")
        }.frame(height: 60)
            .contentShape(Rectangle())
            .gesture(
                TapGesture().onEnded {
                    self.showPreview = true
                }
            )
            .background(
                DocumentPreviewViewController(
                    self.$showPreview,
                    url: self.documentsURL
                )
            )
            .task {
                await downloadConsent()
            }
    }

    init() {
        Task {
            //await downloadConsent()
        }
    }

    @MainActor func downloadConsent() async {
        do {
            let manager = CKConsentManager()
            let url = try await manager.downloadConsent()
            self.documentsURL = url
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct DDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView()
    }
}
