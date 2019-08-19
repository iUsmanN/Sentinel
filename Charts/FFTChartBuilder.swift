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
    var bins                = 25
    
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
