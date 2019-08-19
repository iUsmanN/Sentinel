//
//  ResultsManager.swift
//  AudioKit_Stethoscope
//
//  Created by Usman Nazir on 05/08/2019.
//  Copyright © 2019 Usman Nazir. All rights reserved.
//

import Foundation

protocol CalculatesResults { }

extension CalculatesResults {
    
    //Get the number of peaks above the average threshhold
    func getPeaks() -> Int {
        
        //Count to store number of peaks
        var count       = 0
        
        //Local variables to temporarily store values
        let micInputs   = DataManager.sharedInstance.getMicOutputs()
        let avgInputs   = DataManager.sharedInstance.getDynamicAverage()
        
        //Loop to traverse though the inputs
        for i in 1..<micInputs.count-2 {
            
            //Get the peak index
            if ((micInputs[i-1] < micInputs[i]) && (micInputs[i] > micInputs[i+1])) && (micInputs[i] > avgInputs [i]) {
                count+=1
            }
        }
        //Return count of peaks
        return count
    }
    
    //returns Beats Per Minute
    func getBPM () -> Int {
        return getPeaks() * 4
    }
    
    func findPeak() {
        
        let threshold = 100.0
        var peak = false
        
        for i in 2...8 {
            if (DataManager.sharedInstance.dbValues[i] > threshold) {
                peak = true
            }
        }
        
        if peak { print("---") } else { print("-") }
    }
}

/*
 
 - 0 : 0.0
 - 1 : 21.533203125
 - 2 : 43.06640625
 - 3 : 64.599609375
 - 4 : 86.1328125
 - 5 : 107.666015625
 - 6 : 129.19921875
 - 7 : 150.732421875
 - 8 : 172.265625
 - 9 : 193.798828125
 - 10 : 215.33203125
 - 11 : 236.865234375
 - 12 : 258.3984375
 - 13 : 279.931640625
 - 14 : 301.46484375
 - 15 : 322.998046875
 - 16 : 344.53125
 - 17 : 366.064453125
 - 18 : 387.59765625
 - 19 : 409.130859375
 - 20 : 430.6640625
 - 21 : 452.197265625
 - 22 : 473.73046875
 - 23 : 495.263671875
 - 24 : 516.796875
 - 25 : 538.330078125
 
 */
