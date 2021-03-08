//
//  ScheduleViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CareKit
import CareKitStore
import UIKit
import SwiftUI
import CareKitUI

class ScheduleViewController: OCKDailyPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
    }
    
    override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController, prepare listViewController: OCKListViewController, for date: Date) {
        
        let identifiers = ["emaChecklist", "pd1", "pd2", "survey"]
        var query = OCKTaskQuery(for: date)
        query.ids = identifiers
        query.excludesTasksWithNoEvents = true

        storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { result in
            switch result {
            case .failure(let error): print("Error: \(error)")
            case .success(let tasks):
                    
                // Debating whether to keep in depending on if we want fitness tracking too - might be a good visual
                if #available(iOS 14, *), let walkTask = tasks.first(where: { $0.id == "steps" }) {

                    let view = NumericProgressTaskView(
                        task: walkTask,
                        eventQuery: OCKEventQuery(for: date),
                        storeManager: self.storeManager)
                        .padding([.vertical], 10)

                    listViewController.appendViewController(view.formattedHostingController(), animated: false)
                }


                // This was an experiment - an outstanding TODO is better understanding the link between OCKInstructionsTaskView, and
                // OCKInstructionsTaskViewController. Hopefully this can be a point of discussion during our code review. :)
//                if let pd1 = tasks.first(where: { $0.id == "pd1" }) {
//                    let pd1Card = OCKInstructionsTaskViewController(viewSynchronizer: OCKInstructionsTaskViewSynchronizer(),
//                                                        task: pd1,
//                                                        eventQuery: .init(for: date),
//                                                        storeManager: self.storeManager)
//                    listViewController.appendViewController(pd1Card, animated: false)
//                }

                // Adding sample professional development tasks (abbr: pd)
                if let pd1 = tasks.first(where: { $0.id == "pd1" }) {
                    let pd1Card = OCKSimpleTaskViewController(task: pd1, eventQuery: .init(for: date),
                                                                 storeManager: self.storeManager)
                    listViewController.appendViewController(pd1Card, animated: false)
                }
                if let pd2 = tasks.first(where: { $0.id == "pd2" }) {
                    let pd2Card = OCKSimpleTaskViewController(task: pd2, eventQuery: .init(for: date),
                                                                 storeManager: self.storeManager)
                    listViewController.appendViewController(pd2Card, animated: false)
                }
                
                if let surveyTask = tasks.first(where: { $0.id == "survey" }), let emaChecklistTask = tasks.first(where: { $0.id == "emaChecklist" }) {
                    let surveyCard = SurveyItemViewController(
                        viewSynchronizer: SurveyItemViewSynchronizer(),
                        task: surveyTask,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)
                    
                    let emaChecklistCard = OCKChecklistTaskViewController(
                        task: emaChecklistTask,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)
                    listViewController.appendViewController(surveyCard, animated: false)
                    listViewController.appendViewController(emaChecklistCard, animated: false)

                    let emaGradientStart = UIColor { traitCollection -> UIColor in
                        return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) : #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                    }
                    let emaGradientEnd = UIColor { traitCollection -> UIColor in
                        return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) : #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                    }
                    
                    let emaDataSeries = OCKDataSeriesConfiguration(
                        taskID: "emaChecklist",
                        legendTitle: "Survey Completion",
                        gradientStartColor: emaGradientStart,
                        gradientEndColor: emaGradientEnd,
                        markerSize: 10,
                        eventAggregator: OCKEventAggregator.countOutcomeValues)

                    let insightsCard = OCKCartesianChartViewController(
                        plotType: .bar,
                        selectedDate: date,
                        configurations: [emaDataSeries],
                        storeManager: self.storeManager)
                    
                    insightsCard.chartView.headerView.titleLabel.text = "Survey Completion Progress"
                    insightsCard.chartView.headerView.detailLabel.text = "This Week"
                    insightsCard.chartView.headerView.accessibilityLabel = "Survey Completion Progress, This Week"
                    listViewController.appendViewController(insightsCard, animated: false)
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
