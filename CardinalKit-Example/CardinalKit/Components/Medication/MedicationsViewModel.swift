//
//  MedicationsViewModel.swift
//  Medication-Autocomplete
//
//  Created by Vishnu Ravi on 3/13/21.
//

import SwiftUI
import Combine
import Firebase
import CareKit
import CareKitStore

class MedicationsViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var selectedMedication: String = ""
    @Published var medications: [Medication] = [Medication]()
    @Published var isShowingMedicationDetailView: Bool = false
    
    var allMedications: [String] = [String]()
    var filteredMedications: [String] = [String]()
    var publisher: AnyCancellable?
    
    func clearSearch() -> Void {
        self.searchText = ""
    }
    
    //let coreDataStore = OCKStore(name: "CKCareKitStore", type: .inMemory)
    let coreDataStore = OCKStore(name: "CKCareKitStore", type: .onDisk, remote: CKCareKitRemoteSyncWithFirestore())
    
    func getMedications() {
//        var query = OCKTaskQuery()
//        query.excludesTasksWithNoEvents = true
//        coreDataStore.fetchTasks(query: query, callbackQueue: .main) { result in
//            switch result {
//            case .failure(let error): print("Error: \(error)")
//            case .success(let tasks):
//                var medicationTasks: [Medication] = []
//                tasks.forEach { task in
//                    if task.id.contains("medications") {
//                        print("medication task: " + task.id)
//                    }
//                    if task.tags!.count >= 5{
//                        var times:[String] = []
//                        for i in 4..<task.tags!.count {
//                            times.append(task.tags![i])
//                        }
//                        medicationTasks.append(Medication(id: task.tags![0], name: task.tags![1], dosage: task.tags![2], unit: task.tags![3], times: times))
//                    }
//                }
//                self.medications = medicationTasks
//            }
//        }
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
                        let firestoreMeds:[String] = document.get("medications") as! [String]
                    
                        firestoreMeds.forEach {medString in
                            let med = medString.split(separator: ",").map({ (substring) in
                                return String(substring)
                            })
                            var times:[String] = []
                            for i in 4..<med.count {
                                times.append(med[i])
                            }
                            let medObject = Medication(id: med[0], name: med[1], dosage: med[2], unit: med[3], times: times)
                            self.medications.append(medObject)
                        }

                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    init() {
        getMedications()
        
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
                        .sorted(by: <)
                        .sorted { ($0.lowercased().hasPrefix(str.lowercased()) ? 0 : 1) < ($1.lowercased().hasPrefix(str.lowercased()) ? 0 : 1)}
                }else{
                    self.filteredMedications = []
                }
            })
    }
}
