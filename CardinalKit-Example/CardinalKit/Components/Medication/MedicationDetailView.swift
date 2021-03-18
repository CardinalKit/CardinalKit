//
//  MedicationDetailView.swift
//  Medication-Autocomplete
//
//  Created by Vishnu Ravi on 3/15/21.
//

import SwiftUI
import CareKit
import CareKitStore

struct MedicationDetailView: View {
    
    @ObservedObject var medicationsViewModel: MedicationsViewModel
    
    @State private var selectedDosage: String = ""
    
    @State private var selectedUnit: String = ""
    var units: [String] = ["tablet(s)", "capsule(s)", "milliliters", "units", "grams", "milligrams"]

    @State var times: [String] = ["6-8AM", "10AM", "12PM", "6PM", "10PM"]
    @State var selectedTimes: [String] = []
    
    
    private var isNotValidated: Bool {
        return self.selectedDosage.isEmpty || self.selectedUnit.isEmpty || self.selectedTimes.isEmpty
    }
    
    //let coreDataStore = OCKStore(name: "CKCareKitStore", type: .inMemory)
    let coreDataStore = OCKStore(name: "CKCareKitStore", type: .onDisk, remote: CKCareKitRemoteSyncWithFirestore())
    
    var body: some View {
        VStack {
            VStack {
                NavigationView {
                    if #available(iOS 14.0, *) {
                        Form {
                            Section(header: Text("Dosage")) {
                                HStack{
                                    TextField("Quantity", text: $selectedDosage)
                                        .keyboardType(.decimalPad)
                                    Picker("Unit", selection: $selectedUnit){
                                        ForEach(units, id: \.self){
                                            Text($0)
                                        }
                                    }
                                }
                            }
                            Section(header: Text("Times")) {
                                List {
                                    ForEach(times, id: \.self) { item in
                                        MultipleSelectionRow(title: item, isSelected: self.selectedTimes.contains(item)) {
                                            if self.selectedTimes.contains(item) {
                                                self.selectedTimes.removeAll(where: { $0 == item })
                                            }
                                            else {
                                                self.selectedTimes.append(item)
                                            }
                                        }
                                    }
                                }
                            }
                        }.navigationTitle(self.medicationsViewModel.selectedMedication)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            Spacer()
            HStack {
                Button("Add this Medication"){
                    let newMed = Medication(name: self.medicationsViewModel.selectedMedication, dosage: selectedDosage, unit: selectedUnit, times: selectedTimes)
                    self.medicationsViewModel.medications.append(newMed)
                    coreDataStore.addMedication(medication: newMed)
                    CKStudyUser.shared.saveMedication(medication: newMed)
                    self.medicationsViewModel.clearSearch()
                }
                .padding()
                .foregroundColor(Color.white)
                .background(Color.blue)
                .cornerRadius(5)
                .disabled(self.isNotValidated)
                .opacity(self.isNotValidated ? 0.5 : 1)
                
                Button("Cancel"){
                    self.medicationsViewModel.clearSearch()
                    self.medicationsViewModel.isShowingMedicationDetailView.toggle()
                }
                .padding()
                .foregroundColor(Color.white)
                .background(Color.blue)
                .cornerRadius(5)
            }
            Spacer()
        }.background(Color(UIColor.systemGray5))
    }
}
