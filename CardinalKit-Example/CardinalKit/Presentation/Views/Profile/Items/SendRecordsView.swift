//
//  SendRecordsView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/23/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import CardinalKit

struct SendRecordsView: View {
    
    @State var lastSentString: String? = nil
    @State var lastSentDate: Date? = nil {
        didSet {
            if let lastSentDate = lastSentDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy h:mm a"
                lastSentString = formatter.string(from: lastSentDate)
            }
        }
    }
    
    fileprivate var recordsLastUploaded: Date? {
        get {
            return UserDefaults.standard.object(forKey: Constants.prefHealthRecordsLastUploaded) as? Date
        }
    }
    
    fileprivate func onPress() {
        var lastDate = Date().yesterday
        if let recordsLastUploaded = lastSentDate {
            lastDate = recordsLastUploaded
        }
        CKApp.collectData(fromDate: lastDate, toDate: Date())
        lastSentDate = Date()
        UserDefaults.standard.set(Date(), forKey: Constants.prefHealthRecordsLastUploaded)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Upload Health Records")
                    .foregroundColor(.blue)
                if let lastSentString = lastSentString {
                    Text("Last sent on \(lastSentString)")
                        .foregroundColor(.gray)
                        .font(Font.footnote)
                }
            }
            Spacer()
        }.frame(height: 70)
        .contentShape(Rectangle())
        .gesture(TapGesture().onEnded(onPress))
        .onAppear(perform: {
            lastSentDate = recordsLastUploaded
        })
    }
}

struct SendRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        SendRecordsView()
    }
}
