//
//  AudioManager.swift
//  AudioKit_Stethoscope
//
//  Created by Usman Nazir on 05/08/2019.
//  Copyright © 2019 Usman Nazir. All rights reserved.
//

import AudioKit
import AudioKitUI

// Treat the conductor like a manager for the audio engine.
class AudioManager {
    
    //Inputs
    var inputDevices            = AudioKit.inputDevices ?? []
    
    // Singleton of the Conductor class to avoid multiple instances of the audio engine
    static let sharedInstance   = AudioManager()
    
    // Create instance variables
    var mic                     : AKMicrophone!
    var tracker                 : AKFrequencyTracker!//AKAmplitudeTracker!
    var boost                   : AKBooster!
    var bandPass                : AKBandPassButterworthFilter!
    var lowpass                 : AKLowPassFilter!
    var recorder                : AKNodeRecorder!
    var equalizerPositive       : AKEqualizerFilter!
    var equalizerNegative       : AKEqualizerFilter!
    
    //Array to store amplitudes
    var averageArray            = [Double]()
    var micDataArray            = [Double]()
    
    //Manual Amplification
    var ampFactor               = 1
    
    //Average
    var sum : Double            = 0
    
    //Closure to pass Arr
    var updateChart             : (() -> ())!
    var showResults             : (() -> ())!
    
    private init() {
        
        //Create file for storing audio (Unused)
        //let _                       = getFileForRecording()
        
        // Capture mic input
        mic                         = AKMicrophone()
        
        //Add Low pass filter at 420 Hz to remove noise (giving mic as input)
        lowpass                     = AKLowPassFilter(mic)
        lowpass.cutoffFrequency     = 420
        
        //Add Butterworth bandpass filter to only have frequencies from 20Hz to 420Hz (giving the low pass output as input)
        bandPass                    = AKBandPassButterworthFilter(lowpass)
        bandPass.centerFrequency    = 220
        bandPass.bandwidth          = 200
        
        //Amplify the low frequency sound (giving the band pass output as the input)
        equalizerPositive           = AKEqualizerFilter(bandPass, centerFrequency: bandPass.centerFrequency, bandwidth: bandPass.bandwidth, gain: 4)
        
        //Deamplifying the high frequency sound for further clarity (giving the positively amplified output as input)
        equalizerNegative           = AKEqualizerFilter(equalizerPositive, centerFrequency: 10210, bandwidth: 9790, gain: -4)
        
        // Pull Amplified output into the tracker node.
        tracker                     = AKFrequencyTracker(equalizerNegative)
        
        //ADD ADDITIONAL NODES HERE
        
        // Assign the output to be the final audio output
        AudioKit.output             = tracker
        
        //Start Engine After 2s
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            
            //Start Audio Engine
            self.startAudioEngine()
            self.lowpass.start()
            self.bandPass.start()
            self.tracker.start()
            
            //Capture Values every 0.1s
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
                
                print(self.tracker.frequency)
                
                //Save amplified data to array2 (Multiplied by 1000 to draw it on graph)
                self.micDataArray.append(self.tracker.amplitude * self.ampFactor)
                
                //Save dynamic average in array
                self.averageArray.append(self.getAverage(input: self.tracker.amplitude * self.ampFactor) * 1.2)//(frequency!)
            }
            
            //Stop Recording after 15s
            Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { timer in
                self.stopAudioEngine()
                
                //Save Data in Data Manager
                DataManager.sharedInstance.setMicOutputs(input: self.micDataArray)
                DataManager.sharedInstance.setDynamicAvgs(input: self.averageArray)
                
                //Update chart
                self.updateChart()
                
                //Show BPM count
                self.showResults()
            }
        }
    }
    
    //Return file for recording
    func getFileForRecording() -> AKAudioFile? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recorded")
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat64, sampleRate: 44100, channels: 2, interleaved: false)!
        let tape = try? AKAudioFile(forWriting: url, settings: format.settings)
        return tape
    }
    
    //Sets closure to return data to the Chart Builder
    func setReturnClosure(closure2: @escaping () -> (), closure: @escaping ()->()) {
        updateChart = closure2
        showResults = closure
    }
    
    //Automatically called
    internal func startAudioEngine() {
        try? AudioKit.start()
        print("Audio engine started")
    }
    
    //Automatically called
    internal func stopAudioEngine() {
        try? AudioKit.stop()
        print("Audio engine stopped")
    }
    
    //Calculates dynamic average
    @discardableResult
    func getAverage(input: Double) -> Double {
        var sum: Double = 0
        for i in micDataArray {
            sum += i
        }
        return sum/micDataArray.count
    }
    
    //Custom LowPass Filter
    func removeHighFrequencyData(inputTracker: AKFrequencyTracker, cutOff: Double) -> (Double?, Double?) {
        if tracker.frequency < cutOff {
            return (inputTracker.frequency, inputTracker.amplitude)
        } else { return (0.0, 0.0) }
    }
}
