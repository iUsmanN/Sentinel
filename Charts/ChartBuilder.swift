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

class ChartBuilder {
    
    //Line chart view
    var view : LineChartView!
    
    //Stores chart data entry values
    var averagesArray = [ChartDataEntry]()
    var MicrophoneArray = [ChartDataEntry]()
    
    //Initializes class with chart view
    init(inputView: LineChartView) {
        view = inputView
    }
    
    func fetchData() {
        
        //Used for graph x axis
        var x = 0
        
        //Populate array for Amplitudes by getting values from data manager singleton
        for i in DataManager.sharedInstance.getMicOutputs() {
            
            //Store value
            MicrophoneArray.append(ChartDataEntry(x: Double(x), y: i))
            
            //increase x-axis value
            x+=1
        }
        
        //Reset graph x scale
        x = 0
        
        //Populate array for Averages by getting values from data manager singleton
        for i in DataManager.sharedInstance.getDynamicAverage() {
            
            //Store value
            averagesArray.append(ChartDataEntry(x: Double(x), y: i))
            
            //increase x-axis value
            x+=1
        }
        
        //Draw chart
        drawChart()
    }
    
    //Draws the chart
    func drawChart() {
        
        //Prepare data set 1
        let linedataset = LineChartDataSet(entries: averagesArray, label: nil)
        linedataset.circleHoleColor = .clear
        linedataset.setColor(.white)
        linedataset.circleRadius = 0
        
        
        //Prepare dataset 2
        let linedataset2 = LineChartDataSet(entries: MicrophoneArray, label: nil)
        linedataset2.circleHoleColor = .clear
        linedataset2.setColor(.red)
        linedataset2.circleRadius = 0
        linedataset2.valueTextColor = .white
        
        //Prepare line chart data
        let linechartdata = LineChartData(dataSets: [linedataset, linedataset2])
        
        //Draw chart
        view.data = linechartdata
        
        //Animate chart
        view.animate(xAxisDuration: 1, yAxisDuration: 1, easingOptionX: .easeOutSine, easingOptionY: .easeOutSine)
    }
}
