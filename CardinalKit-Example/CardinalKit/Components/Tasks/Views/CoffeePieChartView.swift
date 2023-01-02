//
//  CoffeePieChartView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 2/17/21.
//  Copyright © 2021 CardinalKit. All rights reserved.
//

import ResearchKit
import SwiftUI


struct CoffeePieChartView: UIViewRepresentable {
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // not implemented
    }

    func makeUIView(context: Context) -> some UIView {
        let config = CKConfig.shared
        let tintColor = config.readColor(query: "Tint Color")
        
        let chartView = ORKPieChartView()
        chartView.tintColor = tintColor
        chartView.showsTitleAboveChart = true
        chartView.title = "Do you drink coffee?"
        chartView.text = "How many cups per day?"
        chartView.noDataText = "Take the coffee survey and come back!"
        
        CoffeeChartDataSource.fetchData { result in
            let dataSource = CoffeeChartDataSource(countPerAnswer: result)
            chartView.dataSource = dataSource
            chartView.animate(withDuration: 1.0)
        }
        
        return chartView
    }
}
