//
//  DocumentView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct DocumentView: View {
    
    @State private var showPreview = false
    var documentsURL: URL? = nil
    
    init() {
        if let documentsPath = UserDefaults.standard.object(forKey: "consentFormURL") as? String {
            self.documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: false)
            print("Opening document at:" + self.documentsURL!.path)
        } else {
            print("No consent document to open")
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


