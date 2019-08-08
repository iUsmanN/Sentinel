//
//  ViewController.swift
//  AudioKit_Stethoscope
//
//  Created by Usman Nazir on 05/08/2019.
//  Copyright © 2019 Usman Nazir. All rights reserved.
//

import UIKit
import AudioKit
import Charts

class ViewController: UIViewController {

    @IBOutlet weak var amplitude    : UILabel!
    @IBOutlet weak var lineChart    : LineChartView!
    @IBOutlet weak var averageLabel : UILabel!
    
    //Array to store amplitudes
    var arr                         = [Double]()
    
    //Obj to build chart
    var chart                       : ChartBuilder?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets the line chart variable
        chart = ChartBuilder(inputView: lineChart)
        
        //Set closure
        if let chart = chart {
            AudioManager.sharedInstance.setReturnClosure(closure2: chart.fetchData, closure: showResults)
        }
    }
}

//View controller calculates results
extension ViewController : CalculatesResults {
    
    //Show results on screen
    func showResults() {
        self.amplitude.text = "BPM : \(getBPM())"
        self.amplitude.textAlignment = .center
    }
}
