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
}
