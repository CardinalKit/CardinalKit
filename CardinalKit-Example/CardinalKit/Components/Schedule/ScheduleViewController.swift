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
        
        let identifiers = ["doxylamine", "medication", "nausea", "coffee", "survey", "steps", "heartRate", "sf12", "check-in", "tremor", "prograf", "tremor-log"]
        var query = OCKTaskQuery(for: date)
        query.ids = identifiers
        query.excludesTasksWithNoEvents = true

        storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { result in
            switch result {
            case .failure(let error): print("Error: \(error)")
            case .success(let tasks):
                // Add a non-CareKit view into the list
//                let tipTitle = "Customize your app!"
//                let tipText = "Start with the CKConfiguration.plist file."
//
//                // Only show the tip view on the current date
//                if Calendar.current.isDate(date, inSameDayAs: Date()) {
//                    let tipView = TipView()
//                    tipView.headerView.titleLabel.text = tipTitle
//                    tipView.headerView.detailLabel.text = tipText
//                    tipView.imageView.image = UIImage(named: "GraphicOperatingSystem")
//                    listViewController.appendView(tipView, animated: false)
//                }

                if #available(iOS 14, *), let walkTask = tasks.first(where: { $0.id == "steps" }) {

                    let view = NumericProgressTaskView(
                        task: walkTask,
                        eventQuery: OCKEventQuery(for: date),
                        storeManager: self.storeManager)
                        .padding([.vertical], 10)

                    listViewController.appendViewController(view.formattedHostingController(), animated: false)
                }
                
                // KidneyCare
                if let sf12Task = tasks.first(where: { $0.id == "sf12" }) {
                    let sf12Card = SF12ViewController(
                        viewSynchronizer: SF12ItemViewSynchronizer(),
                        task: sf12Task,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)
                    
                    listViewController.appendViewController(sf12Card, animated: false)
                }
                
                if let medicationTask = tasks.first(where:  { $0.id == "medication" }) {
                    let medicationCard = OCKSimpleTaskViewController(task: medicationTask, eventQuery: .init(for: date),
                                                                 storeManager: self.storeManager)
                    listViewController.appendViewController(medicationCard, animated: false)
                }
                
                if let checkInTask = tasks.first(where: { $0.id == "check-in" }) {
                    let checkInCard = CheckInViewController(
                        viewSynchronizer: CheckInItemViewSynchronizer(),
                        task: checkInTask,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)
                    
                    listViewController.appendViewController(checkInCard, animated: false)
                }
                
                if let tremorTask = tasks.first(where: { $0.id == "tremor" }) {
                    let tremorCard = TremorTaskViewController(
                        viewSynchronizer: TremorItemViewSynchronizer(),
                        task: tremorTask,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)
                    
                    listViewController.appendViewController(tremorCard, animated: false)
                }
                
                if let prografTask = tasks.first(where: { $0.id == "prograf" }) {

                    let prografCard = OCKChecklistTaskViewController(
                        task: prografTask,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)

                    listViewController.appendViewController(prografCard, animated: false)
                }

                if let tremorLogTask = tasks.first(where: { $0.id == "tremor-log" }) {

                    // dynamic gradient colors
                    let tremorLogGradientStart = UIColor { traitCollection -> UIColor in
                        return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.3725490196, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.2630574384, blue: 0.2592858295, alpha: 1)
                    }
                    let tremorLogGradientEnd = UIColor { traitCollection -> UIColor in
                        return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.4732026144, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.3598620686, blue: 0.2592858295, alpha: 1)
                    }

                    // Create a plot comparing nausea to medication adherence.
                    let tremorLogDataSeries = OCKDataSeriesConfiguration(
                        taskID: "tremor-log",
                        legendTitle: "Tremor",
                        gradientStartColor: tremorLogGradientStart,
                        gradientEndColor: tremorLogGradientEnd,
                        markerSize: 3,
                        eventAggregator: OCKEventAggregator.countOutcomeValues)

                    let prografDataSeries = OCKDataSeriesConfiguration(
                        taskID: "prograf",
                        legendTitle: "Prograf",
                        gradientStartColor: .systemGray2,
                        gradientEndColor: .systemGray,
                        markerSize: 3,
                        eventAggregator: OCKEventAggregator.countOutcomeValues)

                    let insightsCard = OCKCartesianChartViewController(
                        plotType: .line,
                        selectedDate: date,
                        configurations: [prografDataSeries, tremorLogDataSeries],
                        storeManager: self.storeManager)

                    insightsCard.chartView.headerView.titleLabel.text = "Prograf and Tremor Tracking"
                    insightsCard.chartView.headerView.detailLabel.text = "This Week"
                    insightsCard.chartView.headerView.accessibilityLabel = "Prograf and Tremor Tracking, This Week"
                    
                    let tremorLogCard = OCKButtonLogTaskViewController(task: tremorLogTask, eventQuery: .init(for: date),
                                                                    storeManager: self.storeManager)
                    listViewController.appendViewController(tremorLogCard, animated: false)
                    listViewController.appendViewController(insightsCard, animated: false)
                }

                // Since the coffee task is only scheduled every other day, there will be cases
                // where it is not contained in the tasks array returned from the query.
//                if let coffeeTask = tasks.first(where: { $0.id == "coffee" }) {
//                    let coffeeCard = OCKSimpleTaskViewController(task: coffeeTask, eventQuery: .init(for: date),
//                                                                 storeManager: self.storeManager)
//                    listViewController.appendViewController(coffeeCard, animated: false)
//                }
//
//                if let surveyTask = tasks.first(where: { $0.id == "survey" }) {
//                    let surveyCard = SurveyItemViewController(
//                        viewSynchronizer: SurveyItemViewSynchronizer(),
//                        task: surveyTask,
//                        eventQuery: .init(for: date),
//                        storeManager: self.storeManager)
//
//                    listViewController.appendViewController(surveyCard, animated: false)
//                }
//
//                // Create a card for the water task if there are events for it on this day.
//                if let doxylamineTask = tasks.first(where: { $0.id == "doxylamine" }) {
//
//                    let doxylamineCard = OCKChecklistTaskViewController(
//                        task: doxylamineTask,
//                        eventQuery: .init(for: date),
//                        storeManager: self.storeManager)
//
//                    listViewController.appendViewController(doxylamineCard, animated: false)
//                }
//
//                // Create a card for the nausea task if there are events for it on this day.
//                // Its OCKSchedule was defined to have daily events, so this task should be
//                // found in `tasks` every day after the task start date.
//                if let nauseaTask = tasks.first(where: { $0.id == "nausea" }) {
//
//                    // dynamic gradient colors
//                    let nauseaGradientStart = UIColor { traitCollection -> UIColor in
//                        return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.3725490196, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.2630574384, blue: 0.2592858295, alpha: 1)
//                    }
//                    let nauseaGradientEnd = UIColor { traitCollection -> UIColor in
//                        return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.4732026144, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.3598620686, blue: 0.2592858295, alpha: 1)
//                    }
//
//                    // Create a plot comparing nausea to medication adherence.
//                    let nauseaDataSeries = OCKDataSeriesConfiguration(
//                        taskID: "nausea",
//                        legendTitle: "Nausea",
//                        gradientStartColor: nauseaGradientStart,
//                        gradientEndColor: nauseaGradientEnd,
//                        markerSize: 10,
//                        eventAggregator: OCKEventAggregator.countOutcomeValues)
//
//                    let doxylamineDataSeries = OCKDataSeriesConfiguration(
//                        taskID: "doxylamine",
//                        legendTitle: "Doxylamine",
//                        gradientStartColor: .systemGray2,
//                        gradientEndColor: .systemGray,
//                        markerSize: 10,
//                        eventAggregator: OCKEventAggregator.countOutcomeValues)
//
//                    let insightsCard = OCKCartesianChartViewController(
//                        plotType: .bar,
//                        selectedDate: date,
//                        configurations: [nauseaDataSeries, doxylamineDataSeries],
//                        storeManager: self.storeManager)
//
//                    insightsCard.chartView.headerView.titleLabel.text = "Nausea & Doxylamine Intake"
//                    insightsCard.chartView.headerView.detailLabel.text = "This Week"
//                    insightsCard.chartView.headerView.accessibilityLabel = "Nausea & Doxylamine Intake, This Week"
//                    listViewController.appendViewController(insightsCard, animated: false)
//
//                    // Also create a card that displays a single event.
//                    // The event query passed into the initializer specifies that only
//                    // today's log entries should be displayed by this log task view controller.
//                    let nauseaCard = OCKButtonLogTaskViewController(task: nauseaTask, eventQuery: .init(for: date),
//                                                                    storeManager: self.storeManager)
//                    listViewController.appendViewController(nauseaCard, animated: false)
//                }
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
