//
//  ScheduleViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CareKit
import UIKit
import SwiftUI
import CardinalKit
import ResearchKit
import CareKitStore

class ScheduleViewController: OCKDailyPageViewController {
    let surveyManager:SurveyManager
    
    init() {
        let coordinator = OCKStoreCoordinator()
        surveyManager = Dependencies.container.resolve(SurveyManager.self)!
        super.init(storeManager: OCKSynchronizedStoreManager(wrapping: coordinator))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
    }
    
    override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController, prepare listViewController: OCKListViewController, for date: Date) {
        
//        let tipTitle = "Customize your app!"
//        let tipText = "Start with the CKConfiguration.plist file."
//        if Calendar.current.isDate(date, inSameDayAs: Date()) {
//            let tipView = TipView()
//            tipView.headerView.titleLabel.text = tipTitle
//            tipView.headerView.detailLabel.text = tipText
//            tipView.imageView.image = UIImage(named: "GraphicOperatingSystem")
//            listViewController.appendView(tipView, animated: false)
//        }
        
        
        CKApp.requestScheduleItems(date: date){ response in
            for item in response{
                switch (item.type){
                case .survey:
                    // Get survey Data from firebase
                    self.surveyManager.foundSurvey(surveyId: item.surveyId!){ task in
                        let card = SurveyItemViewController(task: task, scheduleItem:item, storeManager: self.storeManager)
                        listViewController.appendViewController(card, animated: false)
                    }
                    
                default:
                    print("Mode do not supported yet")
                    }
            }
        }
    }
    
}

private extension View {
    func formattedHostingController() -> UIHostingController<Self> {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = .clear
        return viewController
    }
}
