//
//  MainPresenter.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 5/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CardinalKit

class MainPresenter: ObservableObject {
    @Published var useCarekit:Bool = false
    @Published var carekitLoaded:Bool = false
    
    init(){
        CKApp.collectData(fromDate: Date().dayByAdding(-10)!, toDate: Date())
        
        let config = CKConfig.shared
        self.useCarekit = config.readBool(query: "Use CareKit")
        let lastUpdateDate:Date? = UserDefaults.standard.object(forKey: Constants.prefCareKitCoreDataInitDate) as? Date
        self.carekitLoaded = true
        CKCareKitManager.shared.coreDataStore.createContacts()
//        CKCareKitManager.shared.coreDataStore.populateSampleData(lastUpdateDate:lastUpdateDate){() in
//            self.carekitLoaded = true
//        }
    }
}
