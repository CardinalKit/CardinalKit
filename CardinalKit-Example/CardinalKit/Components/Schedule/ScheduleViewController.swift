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

class ScheduleViewController: OCKDailyPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
    }
    
    override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController, prepare listViewController: OCKListViewController, for date: Date) {
        
        let identifiers = ["doxylamine", "nausea", "coffee", "heartRate", "survey", "steps", "heartRate", "heartrate-2", "bloodpressure", "drug", "diary"]
        var query = OCKTaskQuery(for: date)
        query.ids = identifiers
        query.excludesTasksWithNoEvents = true

        storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { result in
            switch result {
            case .failure(let error): print("Error: \(error)")
            case .success(let tasks):
                
                print("Tasks: ")
                for task in tasks {
                    print("\(task.id)")
                }

                // Add a non-CareKit view into the list
                let tipTitle = "Customize your app!"
                let tipText = "Start with the CKConfiguration.plist file."

                // Only show the tip view on the current date
                if Calendar.current.isDate(date, inSameDayAs: Date()) {
                    let tipView = TipView()
                    tipView.headerView.titleLabel.text = tipTitle
                    tipView.headerView.detailLabel.text = tipText
                    tipView.imageView.image = UIImage(named: "GraphicOperatingSystem")
                    listViewController.appendView(tipView, animated: false)
                }

                if #available(iOS 14, *), let walkTask = tasks.first(where: { $0.id == "steps" }) {

                    let view = NumericProgressTaskView(
                        task: walkTask,
                        eventQuery: OCKEventQuery(for: date),
                        storeManager: self.storeManager)
                        .padding([.vertical], 10)

                    listViewController.appendViewController(view.formattedHostingController(), animated: false)
                }

                // Since the coffee task is only scheduled every other day, there will be cases
                // where it is not contained in the tasks array returned from the query.
                if let coffeeTask = tasks.first(where: { $0.id == "coffee" }) {
                    let coffeeCard = OCKSimpleTaskViewController(task: coffeeTask, eventQuery: .init(for: date),
                                                                 storeManager: self.storeManager)
                    listViewController.appendViewController(coffeeCard, animated: false)
                }
                
                if let surveyTask = tasks.first(where: { $0.id == "survey" }) {
                    let surveyCard = SurveyItemViewController(
                        viewSynchronizer: SurveyItemViewSynchronizer(),
                        task: surveyTask,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)
                    
                    listViewController.appendViewController(surveyCard, animated: false)
                }
                
                if let heartrateTask = tasks.first(where: { $0.id == "heartrate-2" }) {
                    let surveyCard = BloodPressureItemViewController(
                        viewSynchronizer: BloodPressureItemViewSynchronizer(),
                        task: heartrateTask,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)
                    
                    listViewController.appendViewController(surveyCard, animated: false)
                }
                
                if let bloodpressureTask = tasks.first(where: { $0.id == "bloodpressure" }) {
                    let surveyCard = BloodPressureItemViewController(
                        viewSynchronizer: BloodPressureItemViewSynchronizer(),
                        task: bloodpressureTask,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)
                    
                    listViewController.appendViewController(surveyCard, animated: false)
                } else {
                    print("Couldn't find the task!")
                }

                // Drug and Diary Tasks
                if let diaryTask = tasks.first(where: { $0.id == "diary" }) {

                    // dynamic gradient colors
                    let diaryGradientStart = UIColor { traitCollection -> UIColor in
                        return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.3725490196, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.2630574384, blue: 0.2592858295, alpha: 1)
                    }
                    let diaryGradientEnd = UIColor { traitCollection -> UIColor in
                        return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.4732026144, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.3598620686, blue: 0.2592858295, alpha: 1)
                    }

                    // Create a plot comparing diary to medication adherence.
                    let diaryDataSeries = OCKDataSeriesConfiguration(
                        taskID: "diary",
                        legendTitle: "Apples Eaten",
                        gradientStartColor: diaryGradientStart,
                        gradientEndColor: diaryGradientEnd,
                        markerSize: 10,
                        eventAggregator: OCKEventAggregator.countOutcomeValues)

                    let drugDataSeries = OCKDataSeriesConfiguration(
                        taskID: "drug",
                        legendTitle: "Drugs Taken",
                        gradientStartColor: .systemGray2,
                        gradientEndColor: .systemGray,
                        markerSize: 10,
                        eventAggregator: OCKEventAggregator.countOutcomeValues)

                    let insightsCard = OCKCartesianChartViewController(
                        plotType: .bar,
                        selectedDate: date,
                        configurations: [diaryDataSeries, drugDataSeries],
                        storeManager: self.storeManager)

                    insightsCard.chartView.headerView.titleLabel.text = "Diary & Drug Intake"
                    insightsCard.chartView.headerView.detailLabel.text = "This Week"
                    insightsCard.chartView.headerView.accessibilityLabel = "Diary & Drug Intake, This Week"
                    listViewController.appendViewController(insightsCard, animated: false)

                    // Also create a card that displays a single event.
                    // The event query passed into the initializer specifies that only
                    // today's log entries should be displayed by this log task view controller.
                    let diaryCard = OCKButtonLogTaskViewController(task: diaryTask,
                                                                   eventQuery: .init(for: date),
                                                                   storeManager: self.storeManager)
                    listViewController.appendViewController(diaryCard, animated: false)
                }
                
                if let drugTask = tasks.first(where: { $0.id == "drug" }) {

                    let drugCard = OCKChecklistTaskViewController(
                        task: drugTask,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)

                    listViewController.appendViewController(drugCard, animated: false)
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
