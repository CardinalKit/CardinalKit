//
//  DocumentView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import Firebase

struct DocumentView: View {
    
    @State private var showPreview = false
    var documentsURL: URL? = nil
    
    init() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        if let DocumentCollection = CKStudyUser.shared.authCollection {
            let config = CKPropertyReader(file: "CKConfiguration")
            let DocumentRef = storageRef.child("\(DocumentCollection)/Consent.pdf")
            // Create local filesystem URL
            var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
            docURL = docURL?.appendingPathComponent("\(config.read(query: "Consent File Name")).pdf") as NSURL?
            let url = docURL! as URL
            self.documentsURL = URL(fileURLWithPath: url.path, isDirectory: false)
            UserDefaults.standard.set(url.path, forKey: "consentFormURL")
            // Download to the local filesystem
            let downloadTask = DocumentRef.write(toFile: url) { url, error in
              if let error = error {
                // Uh-oh, an error occurred!
                  print("error \(error)")
              } else {
                  print("download correctly")
              }
            }
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


