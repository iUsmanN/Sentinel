//
//  DataManager.swift
//  AudioKit_Stethoscope
//
//  Created by Usman Nazir on 05/08/2019.
//  Copyright © 2019 Usman Nazir. All rights reserved.
//

import Foundation

class DataManager {
    
    //Singleton instance
    static let sharedInstance       = DataManager()
    
    //Stores microphone amplitude data
    var microphoneOutput : [Double] = [Double]()
    
    //Stores average of amplitude data overtime
    var dynamicAverage : [Double]   = [Double]()
    
    //Stores Frequency Intervals
    var frequencyIntervals : [Double] = [Double]()
    
    //Stores dB Values
    var dbValues : [Double] = [Double]()
    
    //Universal timer for values
    var timer : Double = 0.0
    
    //Sets microphone inputs
    func setMicOutputs(input: [Double]) {
        microphoneOutput = input
    }
    
    //Sets average data
    func setDynamicAvgs(input: [Double]) {
        dynamicAverage = input
    }
    
    //Sets frequency intervals
    func setFrequencyIntervals(input: [Double]) {
        frequencyIntervals = input
    }
    
    //Sets dB data
    func setDbData(input: [Double]) {
        dbValues = input
    }
    
    //Gets microphone data
    func getMicOutputs() -> [Double] {
        return microphoneOutput
    }
    
    //Gets average data
    func getDynamicAverage() -> [Double] {
        return dynamicAverage
    }
    
    //Gets frequency intervals
    func getFrequencyIntervals() -> [Double] {
        return frequencyIntervals
    }
    
    //Gets dB data
    func getDbData() -> [Double] {
        return dbValues
    }
}
