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
        var isStale: Bool = false
        if let data = UserDefaults.standard.data(forKey: "consentFormURL"),
           let documentsURL = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale),
           !isStale {
            return documentsURL
        } else {
            return URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!
        }
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
