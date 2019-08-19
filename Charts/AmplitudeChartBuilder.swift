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

class AmplitudeChartBuilder {
    
    //Line chart view
    var view                : LineChartView!
    
    //Stores chart data entry values
    var averagesArray       = [ChartDataEntry]()
    var MicrophoneArray     = [ChartDataEntry]()
    
    //Initializes class with chart view
    init(inputView: LineChartView) {
        view = inputView
    }
    
    func fetchData() {
        
        MicrophoneArray = [ChartDataEntry]()
        averagesArray   = [ChartDataEntry]()
        
        //Used for graph x axis
        var x = 0.0
        
        //Populate array for Amplitudes by getting values from data manager singleton
        for i in DataManager.sharedInstance.getMicOutputs() {
            
            //Store value
            MicrophoneArray.append(ChartDataEntry(x: Double(x), y: Double(i)))
            
            //increase x-axis value -> Value is 0.05 because of the rate at which values are put from the Audio Manager
            x += 0.05
        }
        
        //Draw chart
        drawChart()
    }
    
    //Draws the chart
    func drawChart() {
        
        //Prepare dataset
        let linedataset2 = LineChartDataSet(entries: MicrophoneArray, label: "Max Frequency Amplitude")
        linedataset2.circleHoleColor = .clear
        linedataset2.setColor(.red)
        linedataset2.circleRadius = 0
        linedataset2.valueTextColor = .white
        
        //Prepare line chart data
        let linechartdata = LineChartData(dataSet: linedataset2)
        
        //Disable value labels on plot line
        linechartdata.setDrawValues(false)
        
        //Set Chart Colors
        view.legend.textColor = .white
        view.xAxis.labelTextColor = .white
        view.leftAxis.labelTextColor = .white
        
        //Draw chart
        view.data = linechartdata
    }
}
