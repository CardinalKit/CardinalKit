//
//  MedicationSelector.swift
//  Medication-Autocomplete
//
//  Created by Vishnu Ravi on 3/13/21.
//

import SwiftUI
import CareKit
import CareKitStore


struct MedicationSelector: View {
     
     @ObservedObject var medicationsViewModel = MedicationsViewModel()
    
    //let coreDataStore = OCKStore(name: "CKCareKitStore", type: .inMemory)
    let coreDataStore = OCKStore(name: "CKCareKitStore", type: .onDisk, remote: CKCareKitRemoteSyncWithFirestore())
     
     func delete(at offsets: IndexSet) {
        offsets.forEach{ i in
            CKStudyUser.shared.deleteMedication(medication: self.medicationsViewModel.medications[i])
            let id = "medications-" + self.medicationsViewModel.medications[i].name
            coreDataStore.deleteMedication(medicationId: id)
        }
          self.medicationsViewModel.medications.remove(atOffsets: offsets)
     }
     
     func highlightedText(str: String, searched: String) -> Text {
          guard !str.isEmpty && !searched.isEmpty else { return Text(str) }
          
          var result: Text!
          let parts = str.components(separatedBy: searched)
          for i in parts.indices {
               result = (result == nil ? Text(parts[i]) : result + Text(parts[i]))
               if i != parts.count - 1 {
                    result = result + Text(searched).bold()
               }
          }
          return result ?? Text(str)
     }
     
     var body: some View {
          VStack(alignment: .center) {
               VStack {
                    HStack {
                         ClearableTextField(placeholder: "Enter a medication name...", text: $medicationsViewModel.searchText).autocapitalization(.none).padding()
                    }.padding(.top)
                    
                    
                    if !medicationsViewModel.filteredMedications.isEmpty && !(medicationsViewModel.searchText.isEmpty) {
                         ScrollView {
                              VStack(alignment: .leading){
                                   List {
                                        ForEach(medicationsViewModel.filteredMedications, id: \.self) { medication in
                                             Button(action: {
                                                  self.medicationsViewModel.selectedMedication = medication
                                                  self.medicationsViewModel.isShowingMedicationDetailView.toggle()
                                             }){
                                                  highlightedText(str: medication.lowercased(), searched: self.medicationsViewModel.searchText.lowercased())
                                             }
                                        }
                                   }.frame(height: CGFloat(medicationsViewModel.filteredMedications.count * 50))
                                   Spacer()
                              }
                         }
                         .padding(.bottom)
                         .shadow(radius: 2)
                         .cornerRadius(5)
                         .sheet(isPresented: self.$medicationsViewModel.isShowingMedicationDetailView){
                              MedicationDetailView(medicationsViewModel: self.medicationsViewModel)
                         }
                    }
               }
               Spacer()
               
               if (self.medicationsViewModel.medications.count > 0){
                    Text("Medication List").font(.title)
                    List{
                         ForEach(self.medicationsViewModel.medications, id: \.self){ medication in
                            let medicationTimes = medication.times.joined(separator: ", ")
                              VStack(alignment: .leading, spacing: 0) {
                                   Text(medication.name.uppercased()).font(.headline)
                                Text("Take \(medication.dosage) \(medication.unit) at \(medicationTimes)").font(.subheadline)
                              }
                         }.onDelete(perform: delete)
                    }
               }
               
          }
          
     }
}

struct MedicationSelector_Previews: PreviewProvider {
     static var previews: some View {
          MedicationSelector()
     }
}
