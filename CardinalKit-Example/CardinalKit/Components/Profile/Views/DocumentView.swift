//
//  DocumentView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import CardinalKit

struct DocumentView: View {
    
    @State private var showPreview = false
    var documentsURL: URL? = nil
    
    init() {
        if let DocumentCollection = CKStudyUser.shared.authCollection {
            // download consent document from Firebase Cloud Storage and display it to the user
            let config = CKPropertyReader(file: "CKConfiguration")
            let consentFileName = config.read(query: "Consent File Name")
            var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
            docURL = docURL?.appendingPathComponent("\(consentFileName).pdf") as NSURL?
            let url = docURL! as URL
            self.documentsURL = URL(fileURLWithPath: url.path, isDirectory: false)
            UserDefaults.standard.set(url.path, forKey: "consentFormURL")
            CKApp.getDataFromStorage(path: "\(DocumentCollection)/\(consentFileName).pdf", url: url, onCompletion: {
                success, error in
                if let error = error {
                    print("Error downloading consent document: \(error)")
                } else {
                    print("Consent document downloaded successfully.")
                }
            })
        }
    }
    
    var body: some View {
        HStack {
            Text("View Consent Document")
            Spacer()
            Text("›")
        }.frame(height: 60)
            .contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
                self.showPreview = true
            }))
            .background(DocumentPreviewViewController(self.$showPreview, url: self.documentsURL))
    }
}

struct DDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView()
    }
}


