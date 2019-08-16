//
//  ChartBuilder.swift
//  AudioKit_Stethoscope
//
//  Created by Usman Nazir on 05/08/2019.
//  Copyright © 2019 Usman Nazir. All rights reserved.
//

import Foundation
import Charts
import UIKit

class FFTChartBuilder {
    
    //Number of Bins to Show
    var bins                = 500
    
    //Line chart view
    var view                : LineChartView!
    
    //Stores chart data entry values
    var dB_Array            = [ChartDataEntry]()
    var frequency_Array     = [ChartDataEntry]()
    
    //Initializes class with chart view
    init(inputView: LineChartView) {
        view = inputView
    }
    
    func fetchData() {
        
        //Remove Previous Data
        dB_Array = [ChartDataEntry]()
        
        //Fill Data entries
        for i in 0 ..< bins /*DataManager.sharedInstance.getFrequencyIntervals().count*/ {
            
            dB_Array.append(ChartDataEntry(x: DataManager.sharedInstance.frequencyIntervals[i], y: DataManager.sharedInstance.dbValues[i]))
            
        }
        
        //Draw chart
        drawChart()
    }
    
    //Draws the chart
    func drawChart() {
        
        //Prepare data set 1
        let linedataset = LineChartDataSet(entries: dB_Array, label: "FFT")
        linedataset.circleHoleColor = .clear
        linedataset.setColor(.green)
        linedataset.circleRadius = 0
        
        //Prepare line chart data
        let linechartdata = LineChartData(dataSet: linedataset)
        
        //Draw chart
        view.data = linechartdata
        
        //Animate chart
        //view.animate(xAxisDuration: 1, yAxisDuration: 1, easingOptionX: .easeOutSine, easingOptionY: .easeOutSine)
    }
}
