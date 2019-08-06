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
    
    //Sets microphone inputs
    func setMicOutputs(input: [Double]) {
        microphoneOutput = input
    }
    
    //Sets average data
    func setDynamicAvgs(input: [Double]) {
        dynamicAverage = input
    }
    
    //Gets microphone data
    func getMicOutputs() -> [Double] {
        return microphoneOutput
    }
    
    //Gets average data
    func getDynamicAverage() -> [Double] {
        return dynamicAverage
    }
}
