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
    var bins                = CONSTANTS.VARIABLES.BINS//25
    
    //Line chart view
    var view                : LineChartView!
    
    //Stores chart data entry values
    var dB_Array            = [ChartDataEntry]()
    var threshold_Array     = [ChartDataEntry]()
    var minFreq_Array       = [ChartDataEntry]()
    var maxFreq_Array       = [ChartDataEntry]()
    
    //Initializes class with chart view
    init(inputView: LineChartView) {
        view = inputView
        
        
        minFreq_Array.append(ChartDataEntry(x: Double(CONSTANTS.VARIABLES.MIN_FREQUENCY), y: 0))
        minFreq_Array.append(ChartDataEntry(x: Double(CONSTANTS.VARIABLES.MIN_FREQUENCY), y: 300))
        
        maxFreq_Array.append(ChartDataEntry(x: Double(CONSTANTS.VARIABLES.MAX_FREQUENCY), y: 0))
        maxFreq_Array.append(ChartDataEntry(x: Double(CONSTANTS.VARIABLES.MAX_FREQUENCY), y: 300))
        
    }
    
    func fetchData() {
        
        //Remove Previous Data
        dB_Array = [ChartDataEntry]()
        threshold_Array = [ChartDataEntry]()
        
        //Fill Data entries
        for i in 0 ..< bins {
            
            dB_Array.append(ChartDataEntry(x: DataManager.sharedInstance.frequencyIntervals[i], y: DataManager.sharedInstance.dbValues[i]))
            
            threshold_Array.append(ChartDataEntry(x: DataManager.sharedInstance.frequencyIntervals[i], y: ResultsManager.threshold))
        }
        
        //Draw chart
        drawChart()
    }
    
    //Draws the chart
    func drawChart() {
        
        //Prepare data set
        let linedataset = LineChartDataSet(entries: dB_Array, label: "FFT")
        linedataset.circleHoleColor = .clear
        linedataset.setColor(.green)
        linedataset.circleRadius = 0
        
        //Show Threshold
        let linedataset2 = LineChartDataSet(entries: threshold_Array, label: "Threshold")
        linedataset2.circleHoleColor = .clear
        linedataset2.setColor(.white)
        linedataset2.circleRadius = 0
        linedataset2.lineDashLengths = [3]
        
        //Show Min/Max Lines
        let linedataset3 = LineChartDataSet(entries: minFreq_Array, label: "Min Limit")
        linedataset3.circleHoleColor = .clear
        linedataset3.setColor(.red)
        linedataset3.circleRadius = 0
        linedataset3.lineDashLengths = [3]
        
        let linedataset4 = LineChartDataSet(entries: maxFreq_Array, label: "Max Limit")
        linedataset4.circleHoleColor = .clear
        linedataset4.setColor(.red)
        linedataset4.circleRadius = 0
        linedataset4.lineDashLengths = [3]
        
        //Prepare line chart data
        let linechartdata = LineChartData(dataSets: [linedataset, linedataset2, linedataset3, linedataset4])
        
        //Disable value labels on plot line
        linechartdata.setDrawValues(false)
        
        //Draw chart
        view.data = linechartdata
        
        //Set Chart Colors
        view.legend.textColor = .white
        view.xAxis.labelTextColor = .white
        view.leftAxis.labelTextColor = .white
        
        //Set minimum Y-axis value
        view.leftAxis.axisMinimum = 0
        view.rightAxis.axisMinimum = 0
        
        //Set maximum Y-axis value
        view.leftAxis.axisMaximum = 300
        view.rightAxis.axisMaximum = 300
    }
}
