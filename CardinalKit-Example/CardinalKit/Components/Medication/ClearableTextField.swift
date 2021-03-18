//
//  ClearableTextField.swift
//  Medication-Autocomplete
//
//  Created by Vishnu Ravi on 3/13/21.
//

import SwiftUI

struct ClearableTextField: View {
    private var text: Binding<String>
    private var placeholder: String
    
    init(placeholder: String = "", text: Binding<String>){
        self.placeholder = placeholder
        self.text = text
    }

    var body: some View {
        TextField(placeholder, text: text)
            .clearable(text: text)
    }
}

extension TextField {
    func clearable(text: Binding<String>) -> some View {
        self.modifier(ClearableModifier(text: text))
    }
}

struct ClearableModifier: ViewModifier {
    @Binding var text: String
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            if(!text.isEmpty){
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
