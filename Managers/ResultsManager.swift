//
//  ResultsManager.swift
//  AudioKit_Stethoscope
//
//  Created by Usman Nazir on 19/08/2019.
//  Copyright © 2019 Usman Nazir. All rights reserved.
//

import Foundation

class ResultsManager {
    
    static let sharedInstance = ResultsManager()
    
    func findPeak() {
        
        let threshold = 100.0
        
        for i in 2...8 {
            if (DataManager.sharedInstance.dbValues[i] > threshold) {
                print("Peak found at :\(DataManager.sharedInstance.timer)")
            }
        }
    }
}
