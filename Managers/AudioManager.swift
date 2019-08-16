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
    var inputDevices            = AudioKit.inputDevices ?? []       //Array holding input devices available
    var mainInputNode           : AKNode!                           //MAIN AUDIO NODE
    
    // Singleton of the Conductor class to avoid multiple instances of the audio engine
    static let sharedInstance   = AudioManager()                    //Audio Manager Instance
    
    // Static variables
    static var mic              : AKMicrophone!                     //Audio Input Microphone
    static var tracker          : AKFrequencyTracker!               //Tracks the frequency of the final processed signal
    
    //Instance Variables
    var player                  : AKPlayer!
    var boost                   : AKBooster!                        //Amplifies the signal
    var bandPass                : AKBandPassButterworthFilter!      //Performs Butterworth Band Pass filtering
    var lowpass                 : AKLowPassFilter!                  //Performs Low Pass Filtering
    var recorder                : AKNodeRecorder!                   //UNUSED
    var equalizerPositive       : AKEqualizerFilter!                //Positively Amplifies required frequencies
    var equalizerNegative       : AKEqualizerFilter!                //Negatively amplifies discardable frequencies
    var FFT                     : AKFFTTap!                         //Tracks the FFT data on the final output
    
    //Array to store amplitudes
    var averageArray            = [Double]()                        //Stores the numeric average values
    var micDataArray            = [Double]()                        //Stores the amplitude values for the chart
    var frequencyArray          = [Double]()                        //Stores the frequency interval values
    var dBArray                 = [Double]()                        //Stores the dB values for the chart
    
    //Manual Amplification
    var ampFactor               = 1                                 //Manual amplification factor
    
    //Closure to pass Arr
    var updateChartFFT          : (() -> ())!                       //Closure to update the chart
    var updateChartAMPL         : (() -> ())!                       //Closure to update the chart
    var showResults             : (() -> ())!                       //Closure to show the results in BPM
    
    private init() {
        
        // Capture mic input
        AudioManager.mic            = AKMicrophone()
        
        //TEST Player
        let file                    = try? AKAudioFile(readFileName: "frequencies2.mp3")
        player                      = try? AKPlayer(audioFile: file!)
        
        //Initial signal Amplification
        boost = AKBooster(AudioManager.mic, gain: 2)
        
        //Add Low pass filter at 420 Hz to remove noise (giving mic as input)
        lowpass                     = AKLowPassFilter(boost)
        lowpass.cutoffFrequency     = 420
        
        //Add Butterworth bandpass filter to only have frequencies from 20Hz to 420Hz (giving the low pass output as input)
        bandPass                    = AKBandPassButterworthFilter(lowpass)
        bandPass.centerFrequency    = 220
        bandPass.bandwidth          = 200
        
        //Amplify the low frequency sound (giving the band pass output as the input)
        equalizerPositive           = AKEqualizerFilter(bandPass, centerFrequency: bandPass.centerFrequency, bandwidth: bandPass.bandwidth, gain: 4)
        
        //Deamplifying the high frequency sound for further clarity (giving the positively amplified output as input)
        equalizerNegative           = AKEqualizerFilter(equalizerPositive, centerFrequency: 10210, bandwidth: 9790, gain: -4)
        
        // MARK: SETUP MAIN INPUT NODE
        //-> Set this to     "equalizerNegative"    to get input from Microphone
        //-> Set this to           "player"         to get input from player. Also call self.player.play() after starting AudioEngine
        mainInputNode = player
        
        //Taps the fft information
        FFT                         = AKFFTTap(mainInputNode)//player)//equalizerNegative)
        
        // Pull Amplified output into the tracker node.
        AudioManager.tracker        = AKFrequencyTracker(mainInputNode)//player)
        
        // Assign the output to be the final audio output
        AudioKit.output             = mainInputNode//AudioManager.mic//player//AudioManager.tracker
        
        //Start Engine After 1s
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            
            //Start Audio Engine
            self.startAudioEngine()
            self.lowpass.start()
            self.bandPass.start()
            
            // MARK: Toggle Player
            self.player.play()
            
            //Start AudioEngine
            AudioManager.tracker.start()
            
            //Capture FFT data every 0.1s
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (_) in
                
                //Print converted raw FFT data
                self.processFFTData(fftTapNode: self.FFT)
                
                //Save Data in Data Manager
                DataManager.sharedInstance.setFrequencyIntervals(input: self.frequencyArray)
                DataManager.sharedInstance.setDbData(input: self.dBArray)
                
                //Refresh FFT Chart
                self.updateChartFFT()
            }
            
            //Capture Amplitude data every 0.1s
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_) in
                
                //Save amplified data to array2 (Multiplied by 1000 to draw it on graph)
                //self.micDataArray.append((self.FFT.fftData.max()! * 1000000000))
                DataManager.sharedInstance.microphoneOutput.append(self.FFT.fftData.max()!)
                
                //Save dynamic average in array
                self.averageArray.append(self.getAverage(input: AudioManager.tracker.amplitude * self.ampFactor) * 1.2)
                
                self.updateChartAMPL()
            })
            
            //Stop Recording after 15s
            Timer.scheduledTimer(withTimeInterval: 150, repeats: false) { timer in
                self.stopAudioEngine()
                
                //Save Data in Data Manager
                DataManager.sharedInstance.setMicOutputs(input: self.micDataArray)
                DataManager.sharedInstance.setDynamicAvgs(input: self.averageArray)
                
                //Update chart Data
                self.updateChartAMPL()
                
                //Show BPM count
                self.showResults()
            }
        }
    }
    
    //Update: WORKS
    //Converts raw FFT Data to frequency and amplitudes based upon :
    // https://stackoverflow.com/questions/52687711/trying-to-understand-the-output-of-akffttap-in-audiokit
    func processFFTData(fftTapNode: AKFFTTap){
        
        frequencyArray = [Double]()
        dBArray = [Double]()
        
        for i in 0...510 {
            
            let re = fftTapNode.fftData[i]
            let im = fftTapNode.fftData[i + 1]
            let normBinMag = 2.0 * sqrt(re * re + im * im)/512
            let amplitude  = 20.0 * log10(normBinMag)
            let frequency  = AKSettings.sampleRate * 0.5 * i/512
            
            print("Frequency: \(frequency), Amplitude: \(amplitude)")
            frequencyArray.append(frequency)
            dBArray.append(amplitude + 200)             //Added 200 to get +ve values
        }
    }
    
    //Sets closure to return data to the Chart Builder
    func setReturnClosure(chartUpdateClosureFFT: @escaping () -> (), chartUpdateClosureAMPL: @escaping () -> (), resultsShowingClosureAMPL: @escaping ()->()) {
        updateChartFFT  = chartUpdateClosureFFT
        updateChartAMPL = chartUpdateClosureAMPL
        showResults     = resultsShowingClosureAMPL
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
        if AudioManager.tracker.frequency < cutOff {
            return (inputTracker.frequency, inputTracker.amplitude)
        } else { return (0.0, 0.0) }
    }
}
