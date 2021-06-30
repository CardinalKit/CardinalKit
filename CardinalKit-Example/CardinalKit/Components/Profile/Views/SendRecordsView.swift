//
//  SendRecordsView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/23/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct SendRecordsView: View {
    
    @State var isSending: Bool = false
    
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
        guard !isSending else { return }
        
        isSending = true
        CKHealthRecordsManager.shared.getAuth { (success, _) in
            guard success else {
                isSending = false
                return
            }
            
            CKHealthRecordsManager.shared.collectAndUploadAll() { success, _ in
                isSending = false
                if success {
                    lastSentDate = recordsLastUploaded
                }
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Upload Health Records")
                    .foregroundColor(isSending ? .gray : .blue)
                if let lastSentString = lastSentString {
                    Text("Last sent on \(lastSentString)")
                        .foregroundColor(.gray)
                        .font(Font.footnote)
                }
            }
            Spacer()
            Text(isSending ? "⏳" : "›")
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
