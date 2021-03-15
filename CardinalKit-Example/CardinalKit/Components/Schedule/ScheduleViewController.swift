//
//  ScheduleViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI
import UIKit
import SwiftUI
import HealthKit
import HealthKitUI

class ScheduleViewController: OCKDailyPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
    }
    
    var systolicDoubleArray: [CGFloat] = []
    var diastolicDoubleArray: [CGFloat] = []
    
    func queryHealthkitLastWeekBPDataStatistic(date: Date) {
        let now = date
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: now)!
        
        var interval = DateComponents()
        interval.day = 1
        
        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: now)
        anchorComponents.hour = 0
        let anchorDate = Calendar.current.date(from: anchorComponents)!
        
        let systolicQuery = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
                                                        quantitySamplePredicate: nil,
                                                        options: .discreteAverage,
                                                        anchorDate: anchorDate,
                                                        intervalComponents: interval)
        
        systolicQuery.initialResultsHandler = {_, results, error in
            print("QUERY RETURNED")
            guard let results = results else {
                print("Error returned form resultHandler = \(String(describing: error?.localizedDescription))")
                return
            }
            self.systolicDoubleArray = []
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let average = statistics.averageQuantity() {
                    let avg = average.doubleValue(for: HKUnit.millimeterOfMercury())
                    self.systolicDoubleArray.append(CGFloat(avg))
                } else {
                    self.systolicDoubleArray.append(0)
                }
            }
        }
        
        let diastolicQuery = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
                                                        quantitySamplePredicate: nil,
                                                        options: .discreteAverage,
                                                        anchorDate: anchorDate,
                                                        intervalComponents: interval)
        
        diastolicQuery.initialResultsHandler = {_, results, error in
            guard let results = results else {
                print("Error returned form resultHandler = \(String(describing: error?.localizedDescription))")
                return
            }
            self.diastolicDoubleArray = []
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let average = statistics.averageQuantity() {
                    let avg = average.doubleValue(for: HKUnit.millimeterOfMercury())
                    self.diastolicDoubleArray.append(CGFloat(avg))
                } else {
                    self.diastolicDoubleArray.append(0)
                }
            }
        }
        
        HKHealthStore().execute(systolicQuery)
        HKHealthStore().execute(diastolicQuery)
    }
    
    func generateLastWeekPressureGraph(date: Date) -> OCKCartesianChartView {
        let bloodPressureSystolicGradientStart = UIColor { traitCollection -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.3725490196, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.2630574384, blue: 0.2592858295, alpha: 1)
        }
        let bloodPressureSystolicGradientEnd = UIColor { traitCollection -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.4732026144, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.3598620686, blue: 0.2592858295, alpha: 1)
        }
        
        let bloodPressureDiastolicGradientStart = UIColor { traitCollection -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) : #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }
        let bloodPressureDiastolicGradientEnd = UIColor { traitCollection -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1) : #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
        
        let chartView = OCKCartesianChartView(type: .bar)
        
        chartView.headerView.titleLabel.text = "Your blood pressure over the last week"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        let lastWeekDateArray = [date.advanced(by: -24 * 60 * 60 * 6),
                                 date.advanced(by: -24 * 60 * 60 * 5),
                                 date.advanced(by: -24 * 60 * 60 * 4),
                                 date.advanced(by: -24 * 60 * 60 * 3),
                                 date.advanced(by: -24 * 60 * 60 * 2),
                                 date.advanced(by: -24 * 60 * 60 * 1),
                                 date]
        let lastWeekDateArrayLabels = lastWeekDateArray.map { (date) -> String in
            return dateFormatter.string(from: date)
        }
        
        let systolicDataSeries = OCKDataSeries(values: systolicDoubleArray, title: "Systolic", gradientStartColor: bloodPressureSystolicGradientStart, gradientEndColor: bloodPressureSystolicGradientEnd)
        
        let diastolicDataSeries = OCKDataSeries(values: diastolicDoubleArray, title: "Diastolic", gradientStartColor: bloodPressureDiastolicGradientStart, gradientEndColor: bloodPressureDiastolicGradientEnd)
        
        chartView.graphView.dataSeries = [systolicDataSeries, diastolicDataSeries]
        chartView.graphView.horizontalAxisMarkers = lastWeekDateArrayLabels
        chartView.graphView.yMinimum = 0
        chartView.graphView.yMaximum = 220
        
        return chartView
    }
    
    override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController, prepare listViewController: OCKListViewController, for date: Date) {
        
        let identifiers = ["doxylamine", "medication", "nausea", "coffee", "survey", "steps", "heartRate", "sf12", "check-in", "tremor", "prograf", "tremor-log", "heartrate-2", "bloodpressure"]
        var query = OCKTaskQuery(for: date)
        query.ids = identifiers
        query.excludesTasksWithNoEvents = true
        queryHealthkitLastWeekBPDataStatistic(date: date)

        storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { [self] result in
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
                if (diastolicDoubleArray.isEmpty || systolicDoubleArray.isEmpty) {
                    print("Error: No blood pressure data found")
                } else if date < Date() {
                    // we don't want to graph in the future, as the HKQueries won't work properly
                    let lastWeekDataCard = generateLastWeekPressureGraph(date: date)
                    listViewController.appendView(lastWeekDataCard, animated: false)
                }

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
