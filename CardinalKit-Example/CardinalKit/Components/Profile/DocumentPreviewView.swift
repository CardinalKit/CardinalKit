//
//  DocumentPreviewView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct DocumentPreviewView: View {
    @State private var showPreview = false
    let documentsURL: URL!
    
    init() {
        let documentsPath = UserDefaults.standard.object(forKey: "consentFormURL")
        self.documentsURL = URL(fileURLWithPath: documentsPath as! String, isDirectory: false)
        print(self.documentsURL.path)
    }
    
    var body: some View {
        HStack {
            Text("View Consent Document")
            Spacer()
            Text("›")
        }.frame(height: 60).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
                self.showPreview = true
                
        })).background(DocumentPreviewViewController(self.$showPreview, url: self.documentsURL))
    }
}
