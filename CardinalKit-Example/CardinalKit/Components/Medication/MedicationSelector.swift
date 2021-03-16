//
//  MedicationSelector.swift
//  Medication-Autocomplete
//
//  Created by Vishnu Ravi on 3/13/21.
//

import SwiftUI
import Firebase
import CareKit
import CareKitStore

struct MedicationSelector: View {
    
    @ObservedObject var medicationsModel = MedicationsViewModel()
    
    @State var medications: [String] = []
    
    func getMedications() {
        if let dataBucket = CKStudyUser.shared.authCollection {
            let db = Firestore.firestore()
            let docRef = db.document(dataBucket)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
//                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                            print("Document data: \(dataDescription)")
                    if (document.get("medications") == nil) {
                        self.medications = []
                        docRef.setData([
                            "medications": []
                        ])
                    }
                    else {
                        self.medications = document.data()!["medications"] as! [String]
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
    //let coreDataStore = OCKStore(name: "CKCareKitStore", type: .inMemory)
    let coreDataStore = OCKStore(name: "CKCareKitStore", type: .onDisk, remote: CKCareKitRemoteSyncWithFirestore())
    
    
    func delete(at offsets: IndexSet) {
        offsets.forEach{ i in
            CKStudyUser.shared.deleteMedication(name: self.medications[i])
            let id = "medications-" + self.medications[i]
            coreDataStore.deleteMedication(medicationId: id)
        }
        
        self.medications.remove(atOffsets: offsets)
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
        ZStack {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    VStack {
                        HStack {
                            ClearableTextField(placeholder: "Enter a medication name...", text: $medicationsModel.searchText).autocapitalization(.none).padding()
                            Button(action: {
                                if (!self.medicationsModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                                    self.medications.append(self.medicationsModel.searchText)
                                    coreDataStore.addMedication(name: self.medicationsModel.searchText)
                                    CKStudyUser.shared.saveMedication(name: self.medicationsModel.searchText)
                                    self.medicationsModel.searchText = ""
                                }
                            }){
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .shadow(radius: 15)
                            }.padding()
                        }.padding(.top)
                        
                        
                        if !medicationsModel.filteredMedications.isEmpty && !(medicationsModel.searchText == "") {
                            ScrollView {
                                VStack(alignment: .leading){
                                    List {
                                        ForEach(medicationsModel.filteredMedications, id: \.self) { medication in
                                            Button(action: {
                                                self.medications.append(medication)
                                                coreDataStore.addMedication(name: medication)
                                                CKStudyUser.shared.saveMedication(name: medication)
                                                self.medicationsModel.searchText = ""
                                            }){
                                                highlightedText(str: medication.lowercased(), searched: self.medicationsModel.searchText.lowercased())
                                            }
                                        }
                                    }.frame(height: CGFloat(medicationsModel.filteredMedications.count * 50))
                                    Spacer()
                                }
                            }
                            .padding()
                            .shadow(radius: 2)
                            .cornerRadius(5)
                        }
                    }
                    
                    List{
                        ForEach(self.medications, id: \.self){ medication in
                            Text(medication)
                        }.onDelete(perform: delete)
                    }.onAppear(perform: getMedications)
                    
                }
                
                Spacer()
                
            }
        }
    }
    }
    
    struct MedicationSelector_Previews: PreviewProvider {
        static var previews: some View {
            MedicationSelector()
        }
    }
