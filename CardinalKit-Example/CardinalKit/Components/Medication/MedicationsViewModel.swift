//
//  MedicationsViewModel.swift
//  Medication-Autocomplete
//
//  Created by Vishnu Ravi on 3/13/21.
//

import SwiftUI
import Combine

class MedicationsViewModel: ObservableObject {
    
    @Published var searchText = ""
    
    var allMedications: [String] = [String]()
    var filteredMedications: [String] = [String]()
    var publisher: AnyCancellable?
    
    init() {
        
        if let medicationsURL = Bundle.main.url(forResource: "medications", withExtension: "csv") {
            if let medications = try? String(contentsOf: medicationsURL) {
                self.allMedications = medications.components(separatedBy: "\n")
            }
        }
        
        self.publisher = $searchText
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (str) in
                if self.searchText.count > 2  {
                    self.filteredMedications = self.allMedications
                        .filter { $0.lowercased().contains(str.lowercased()) }
                        .sorted { ($0.lowercased().hasPrefix(str.lowercased()) ? 0 : 1) < ($1.lowercased().hasPrefix(str.lowercased()) ? 0 : 1)}
                }else{
                    self.filteredMedications = []
                }
            })
    }
}
