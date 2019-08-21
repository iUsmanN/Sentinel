//
//  ResultsManager.swift
//  AudioKit_Stethoscope
//
//  Created by Usman Nazir on 05/08/2019.
//  Copyright © 2019 Usman Nazir. All rights reserved.
//

import Foundation

struct ResultsManager {
    var latestTimeStamp         = -1.0
    var timeStamps              = [Double]()
}

extension ResultsManager {
    
    
    //Dynamically calculate the threshold using the frequency values outside the range
    func calculateThreshold() -> Double {
        return 0
    }

    mutating func findPeak(timer: Double) -> Bool {
        
        //Threshold to get peaks
        let threshold   = 130.0
        
        //Delay to skip/ignore S2 peaks and get only valid peaks
        let s2Delay     = 0.5
        
        var gotPeak = false
        var validTime = false
        
        //Find peaks in range 43Hz and 172 Hz according to the data given at the end of file & in 'Constants' file
        for i in 2...8 {
            if (DataManager.sharedInstance.dbValues[i] > threshold) {
                if(timer > latestTimeStamp + s2Delay) {
                    gotPeak = true
                }
            }
        }
        
        //Check that peak lies after the 40ms interval
        if gotPeak {
            if(timer > latestTimeStamp + 0.4) {
                validTime = true
            }
        }
        
        //if validTime { print("---") } else { print("-") }
        
        return validTime
    }
    
    //Starts populating the heat beat intervals
    mutating func populateCalculationData(timer: Double) -> Bool {
        let showPeak = findPeak(timer: timer)
        
        if showPeak {
            if(timeStamps.count == 0) {
                latestTimeStamp = timer
                timeStamps.append(timer)
            } else {
                //add time stamp
                addTimeStamp(time: timer)
            }
        }
        return showPeak
    }
    
    /// Adds a Valid timestamp into the 'timeStamps' array
    ///
    /// - Parameter time: Current timer value
    mutating func addTimeStamp(time : Double) {
        
        //Get Time stamp
        let timeStamp = makeTimeStamp(time: time)
        
        //Add value to array if it is valid. Valid Ranges : 0.5s and 1.25s are used for a range of 60 - 100bpm (acc to data)
        if(validTimeStamp(timeStamp: timeStamp, minValid: 0.5, maxValid: 1.25)) {
            timeStamps.append(timeStamp)
            print("\(timeStamp) - Accepted")                            //Print added value
        } else { print("\(timeStamp) - Rejected") }                     //Print added value}
    }
    
    
    /// Makes a Time Stamp
    ///
    /// - Parameter time: Current timer value
    /// - Returns: A calculated time Stamp
    mutating func makeTimeStamp(time : Double) -> Double {
        
        //Calculate time stamp
        let timeStamp = time - latestTimeStamp
        
        print("Time Stamp : \(time) - \(latestTimeStamp)")
        //Update latest time
        latestTimeStamp = time
        
        //Returns the current timestamp
        return timeStamp
    }
    
    
    /// Checks if the Timestamp is valid
    ///
    /// - Parameters:
    ///   - timeStamp: Timestamp to check
    ///   - minValid: minimum value in seconds of the timestamp
    ///   - maxValid: maximum value in seconds of the timestamp
    /// - Returns: A Boolean value to confirm if the timestamp is acceptable
    func validTimeStamp(timeStamp : Double, minValid : Double, maxValid : Double) -> Bool {
        
        //Add to calculation if this is a valid time stamp
        if(timeStamp > minValid && timeStamp < maxValid) {
            return true
        }
        
        //Return false if the time stamp does not lie in the required range
        return false
    }
}



/*
 INDEXES : FREQUENCIES
 
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
