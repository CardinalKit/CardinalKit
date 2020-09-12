//
//  ConsentDocumentView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct ConsentDocumentView: View {
    @State private var showPreview = false
    let documentsURL: URL = {
        let documentsPath = UserDefaults.standard.string(forKey: "consentFormURL")
        let documentsURL = URL(fileURLWithPath: documentsPath!, isDirectory: false)
        print(documentsURL.path)
        return documentsURL
    }()

    var body: some View {
        Button("View Consent Document") {
            self.showPreview = true
        }
        .padding(.vertical)
        .background(DocumentPreview(self.$showPreview, url: self.documentsURL))
    }
}

struct ConsentDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        ConsentDocumentView()
    }
}
