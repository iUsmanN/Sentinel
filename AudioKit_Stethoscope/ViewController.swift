//
//  ViewController.swift
//  AudioKit_Stethoscope
//
//  Created by Usman Nazir on 05/08/2019.
//  Copyright © 2019 Usman Nazir. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI
import Charts

class ViewController: UIViewController {
    
    //View objects
    @IBOutlet weak var amplitude    : UILabel!
    @IBOutlet weak var lineChart    : LineChartView!
    @IBOutlet weak var averageLabel : UILabel!
    @IBOutlet var fftplot           : LineChartView!
    
    //Array to store amplitudes
    var arr                         = [Double]()
    
    //Obj to build chart
    var chart                       : AmplitudeChartBuilder?
    var fft                         : FFTChartBuilder?
    
    //Calculates the results in realtime
    var resultsManager              = ResultsManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets the line chart variable
        chart = AmplitudeChartBuilder(inputView: lineChart)
        fft   = FFTChartBuilder(inputView: fftplot)
        
        if let fft = fft, let chart = chart {
            
            //Connect to AudioManager
            AudioManager.sharedInstance.setReturnClosure(chartUpdateClosureFFT: fft.fetchData, chartUpdateClosureAMPL: chart.fetchData, resultsShowingClosureAMPL: showResults(timer:))
        }
    }
}

//View controller calculates results
extension ViewController {
    
    //Show results on screen
    func showResults(timer: Double) {
        if resultsManager.findPeak(timer: timer) {
            amplitude.text = amplitude.text! + "|"
        } else { amplitude.text = amplitude.text! + "." }
    }
}
