//
//  ScheduleViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CareKit
import CareKitUI
import CareKitStore
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
        
        var identifiers = ["doxylamine", "nausea", "coffee", "heartRate", "survey", "steps", "heartRate", "heartrate-2", "bloodpressure", "drug", "diary"]
        
        if let medicationDictionary = SupplementalUserInformation.shared.retrieveSupplementalDictionary()?["medications"] as? Dictionary<String, Int> {
            
            for medicationName in medicationDictionary.keys {
                identifiers.append("drug\(medicationName)")
            }
        }
        
        print("here are the relevant identifiers")
        print(identifiers)
        
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
                    
                    var totalDataSeries = [diaryDataSeries]
                    
                    if let medicationDictionary = SupplementalUserInformation.shared.retrieveSupplementalDictionary()?["medications"] as? Dictionary<String, Int> {
                                                
                        var i = 0
                        for medicationName in medicationDictionary.keys {
                            let drugDataSeries = OCKDataSeriesConfiguration(
                                taskID: "drug\(medicationName)",
                                legendTitle: "\(medicationName)",
                                gradientStartColor: getDataSeriesColor(i: i),
                                gradientEndColor: getDataSeriesColor(i: i).withLuminosity(0.95),
                                markerSize: 10,
                                eventAggregator: OCKEventAggregator.countOutcomeValues)
                            
                            totalDataSeries.append(drugDataSeries)
                            i = i + 1;
                        }
                    }
                    
                    let insightsCard = OCKCartesianChartViewController(
                        plotType: .bar,
                        selectedDate: date,
                        configurations: totalDataSeries,
                        storeManager: self.storeManager)

                    insightsCard.chartView.headerView.titleLabel.text = "Diary & Drug Intake"
                    insightsCard.chartView.headerView.detailLabel.text = "This Week"
                    insightsCard.chartView.headerView.accessibilityLabel = "Diary & Drug Intake, This Week"
                    listViewController.appendViewController(insightsCard, animated: false)
                    
                    // Also create a card that displays a single event.
                    // The event query passed into the initializer specifies that only
                    // today's log entries should be displayed by this log task view controller.
                    if isToday(date: date) {
                        let diaryCard = OCKButtonLogTaskViewController(task: diaryTask,
                                                                       eventQuery: .init(for: date),
                                                                       storeManager: self.storeManager)
                        listViewController.appendViewController(diaryCard, animated: false)
                    }
                }
                
                // enforce that we can only report medications on the present day
                if isToday(date: date) {
                
                    if let medicationDictionary = SupplementalUserInformation.shared.retrieveSupplementalDictionary()?["medications"] as? Dictionary<String, Int> {
                        
                        for medicationName in medicationDictionary.keys {
                            if let drugTask = tasks.first(where: { $0.id == "drug\(medicationName)" }) {

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
        }
    }
}

func isToday(date: Date) -> Bool {
    let order = Calendar.current.compare(date, to: Date(), toGranularity: .day)
    return order == ComparisonResult.orderedSame
}

// Helper function to return some plot colors for different series
// Note: if done in the loop, the color gets overwritten between
// loops; creating the color object here seems to prevent this issue
func getDataSeriesColor(i: Int) -> UIColor {
    
    // Hard code some colors for variety if |drugs| > 1
    let drugColorsLight = [#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)]
    let drugColorsDark =  [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)]
    let count = min(drugColorsLight.count, drugColorsDark.count)
    
    let idx = i % count
    
    return UIColor { traitCollection -> UIColor in
        return traitCollection.userInterfaceStyle == .light ? drugColorsLight[idx] : drugColorsLight[idx]
    }
}

private extension View {
    func formattedHostingController() -> UIHostingController<Self> {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = .clear
        return viewController
    }
}

// The stuff below allows us to programatically adjust the
// luminosity of a given color. For that nice gradient!
// See here:
// https://medium.com/trinity-mirror-digital/adjusting-uicolor-luminosity-in-swift-4168e3c4cdf1
fileprivate extension CGFloat {
    /// clamp the supplied value between a min and max
    /// - Parameter min: The min value
    /// - Parameter max: The max value
    func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        if self < min {
            return min
        } else if self > max {
            return max
        } else {
            return self
        }
    }
        
    /// If colour value is less than 1, add 1 to it. If temp colour value is greater than 1, substract 1 from it
    func convertToColourChannel() -> CGFloat {
        let min: CGFloat = 0
        let max: CGFloat = 1
        let modifier: CGFloat = 1
        if self < min {
            return self + modifier
        } else if self > max {
            return self - max
        } else {
            return self
        }
    }
    
    /// Formula to convert the calculated colour from colour multipliers
    /// - Parameter temp1: Temp variable one (calculated from luminosity)
    /// - Parameter temp2: Temp variable two (calcualted from temp1 and luminosity)
    func convertToRGB(temp1: CGFloat, temp2: CGFloat) -> CGFloat {
       if 6 * self < 1 {
           return temp2 + (temp1 - temp2) * 6 * self
       } else if 2 * self < 1 {
           return temp1
       } else if 3 * self < 2 {
           return temp2 + (temp1 - temp2) * (0.666 - self) * 6
       } else {
           return temp2
       }
   }
}

extension UIColor {
    /// Return a UIColor with adjusted luminosity, returns self if unable to convert
    /// - Parameter newLuminosity: New luminosity, between 0 and 1 (percentage)
    func withLuminosity(_ newLuminosity: CGFloat) -> UIColor {
        // 1 - Convert the RGB values to the range 0-1
        let coreColour = CIColor(color: self)
        var red = coreColour.red
        var green = coreColour.green
        var blue = coreColour.blue
        let alpha = coreColour.alpha
        
        // 1a - Clamp these colours between 0 and 1 (combat sRGB colour space)
        red = red.clamp(min: 0, max: 1)
        green = green.clamp(min: 0, max: 1)
        blue = blue.clamp(min: 0, max: 1)
        
        // 2 - Find the minimum and maximum values of R, G and B.
        guard let minRGB = [red, green, blue].min(), let maxRGB = [red, green, blue].max() else {
            return self
        }
        
        // 3 - Now calculate the Luminace value by adding the max and min values and divide by 2.
        var luminosity = (minRGB + maxRGB) / 2
        
        // 4 - The next step is to find the Saturation.
        // 4a - if min and max RGB are the same, we have 0 saturation
        var saturation: CGFloat = 0
        
        // 5 - Now we know that there is Saturation we need to do check the level of the Luminance in order to select the correct formula.
        //     If Luminance is smaller then 0.5, then Saturation = (max-min)/(max+min)
        //     If Luminance is bigger then 0.5. then Saturation = ( max-min)/(2.0-max-min)
        if luminosity <= 0.5 {
            saturation = (maxRGB - minRGB)/(maxRGB + minRGB)
        } else if luminosity > 0.5 {
            saturation = (maxRGB - minRGB)/(2.0 - maxRGB - minRGB)
        } else {
            // 0 if we are equal RGBs
        }
        
        // 6 - The Hue formula is depending on what RGB color channel is the max value. The three different formulas are:
        var hue: CGFloat = 0
        // 6a - If Red is max, then Hue = (G-B)/(max-min)
        if red == maxRGB {
            hue = (green - blue) / (maxRGB - minRGB)
        }
        // 6b - If Green is max, then Hue = 2.0 + (B-R)/(max-min)
        else if green == maxRGB {
            hue = 2.0 + ((blue - red) / (maxRGB - minRGB))
        }
        // 6c - If Blue is max, then Hue = 4.0 + (R-G)/(max-min)
        else if blue == maxRGB {
            hue = 4.0 + ((red - green) / (maxRGB - minRGB))
        }
        
        // 7 - The Hue value you get needs to be multiplied by 60 to convert it to degrees on the color circle
        //     If Hue becomes negative you need to add 360 to, because a circle has 360 degrees.
        if hue < 0 {
            hue += 360
        } else {
            hue = hue * 60
        }
        
        // we want to convert the luminosity. So we will.
        luminosity = newLuminosity
        
        // Now we need to convert back to RGB
        
        // 1 - If there is no Saturation it means that it’s a shade of grey. So in that case we just need to convert the Luminance and set R,G and B to that level.
        if saturation == 0 {
            return UIColor(red: 1.0 * luminosity, green: 1.0 * luminosity, blue: 1.0 * luminosity, alpha: alpha)
        }
        
        // 2 - If Luminance is smaller then 0.5 (50%) then temporary_1 = Luminance x (1.0+Saturation)
        //     If Luminance is equal or larger then 0.5 (50%) then temporary_1 = Luminance + Saturation – Luminance x Saturation
        var temporaryVariableOne: CGFloat = 0
        if luminosity < 0.5 {
            temporaryVariableOne = luminosity * (1 + saturation)
        } else {
            temporaryVariableOne = luminosity + saturation - luminosity * saturation
        }
        
        // 3 - Final calculated temporary variable
        let temporaryVariableTwo = 2 * luminosity - temporaryVariableOne
        
        // 4 - The next step is to convert the 360 degrees in a circle to 1 by dividing the angle by 360
        let convertedHue = hue / 360
        
        // 5 - Now we need a temporary variable for each colour channel
        let tempRed = (convertedHue + 0.333).convertToColourChannel()
        let tempGreen = convertedHue.convertToColourChannel()
        let tempBlue = (convertedHue - 0.333).convertToColourChannel()

        // 6 we must run up to 3 tests to select the correct formula for each colour channel, converting to RGB
        let newRed = tempRed.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newGreen = tempGreen.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newBlue = tempBlue.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
    }
}
