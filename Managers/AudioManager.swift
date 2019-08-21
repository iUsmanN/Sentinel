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
    
    //Instance Variables
    var player                  : AKPlayer!
    var boost                   : AKBooster!                        //Amplifies the signal
    var bandPass                : AKBandPassButterworthFilter!      //Performs Butterworth Band Pass filtering
    var lowpass                 : AKLowPassFilter!                  //Performs Low Pass Filtering
    var equalizerPositive       : AKEqualizerFilter!                //Positively Amplifies required frequencies
    var equalizerNegative       : AKEqualizerFilter!                //Negatively amplifies discardable frequencies
    var FFT                     : AKFFTTap!                         //Tracks the FFT data on the final output
    
    //Array to store amplitudes
    var frequencyArray          = [Double]()                        //Stores the frequency interval values
    var dBArray                 = [Double]()                        //Stores the dB values for the chart
    
    //Closure to pass Arr
    var updateChartFFT          : (() -> ())!                             //Closure to update the chart
    var updateChartAMPL         : (() -> ())!                             //Closure to update the chart
    var showResults             : ((Double) -> ())!                       //Closure to show the results in BPM
    
    private init() {
        
        // Capture mic input
        AudioManager.mic            = AKMicrophone()
        
        //TEST Player
        let file                    = try? AKAudioFile(readFileName: "heart.mp3")
        player                      = try? AKPlayer(audioFile: file!)
        player.isLooping = true
        
        //Initial signal Amplification
        boost = AKBooster(AudioManager.mic, gain: 3)
        
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
        FFT                         = AKFFTTap(mainInputNode)
        
        // Assign the output to be the final audio output
        AudioKit.output             = mainInputNode
    }
    
    /// Starts the Stethoscope
    func startStethoscope() {
        
        //Start Audio Input and Start AudioEngine
        startAudioInput()
        
        //Set Threshold Immediately
        startThresholding()
        
        //Start BPM Measurement after a delay of 5s
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (_) in
            self.startMeasuringBPM()
        }
        
        //Stop Engine after 20s
        Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { _ in
            self.stopStethoscope()
        }
    }
    
    /// Stops the Stethoscope
    func stopStethoscope() {
        stopAudioEngine()
    }
    
    
    /// Starts Audio Input to the Stethoscope
    func startAudioInput() {
        
        //Start Audio Engine
        self.startAudioEngine()
        self.lowpass.start()
        self.bandPass.start()
        
        // MARK: Toggle Player
        self.player.play()
    }
    
    
    /// Starts to set thresholding values
    func startThresholding() {
        
        //start thresholding mechanism
        
    }
    
    /// Stops setting thresholding values
    func stopThresholding() {
        
        //stop thresholding mechanism
        
    }
    
    
    /// Starts Getting FFT Data for Audio Analysis
    func startMeasuringBPM() {
        
        //Initialize timer
        var timer: Double = 0
        
        //Capture FFT data every 0.05s
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (_) in
            
            //Print converted raw FFT data
            self.processFFTData(fftTapNode: self.FFT, timer: timer)
            
            //Save FFT Data in Data Manager
            DataManager.sharedInstance.setFrequencyIntervals(input: self.frequencyArray)
            DataManager.sharedInstance.setDbData(input: self.dBArray)
            
            //Save timer value
            DataManager.sharedInstance.timer = timer
            
            //Save AMPL Data in Data Manager
            DataManager.sharedInstance.microphoneOutput.append(self.FFT.fftData.max()!)
            
            //Show realtime results
            self.showResults(timer)
            
            //Update timer
            timer += 0.05
            
            //Refresh FFT Chart
            self.updateChartFFT()
            
            //Refresh AMPL Chart
            self.updateChartAMPL()
        }
    }
    
    /// Update: WORKS
    /// Converts raw FFT Data to frequency and amplitudes based upon :
    /// https://stackoverflow.com/questions/52687711/trying-to-understand-the-output-of-akffttap-in-audiokit
    ///
    /// - Parameters:
    ///   - fftTapNode: Raw Data Node
    ///   - timer: Current Time
    func processFFTData(fftTapNode: AKFFTTap, timer: Double){
        
        //Array to hold frequencies
        frequencyArray = [Double]()
        
        //Array to hold frequency amplitude values
        dBArray = [Double]()
        
        //Prepare data for required frequency bins
        for i in 0...CONSTANTS.VARIABLES.BINS {
            
            let re = fftTapNode.fftData[i]
            let im = fftTapNode.fftData[i + 1]
            let normBinMag = 2.0 * sqrt(re * re + im * im) / CONSTANTS.VARIABLES.SAMPLING_RATE
            let amplitude  = 20.0 * log10(normBinMag)
            let frequency  = AKSettings.sampleRate * 0.5 * i / CONSTANTS.VARIABLES.SAMPLING_RATE
            
            frequencyArray.append(frequency)
            dBArray.append(amplitude + 200)             //Added 200 to get +ve values
        }
    }
    
    
    /// Sets closure to return data to the Chart Builder
    ///
    /// - Parameters:
    ///   - chartUpdateClosureFFT: Closure to Update the FFT Chart on screen
    ///   - chartUpdateClosureAMPL: Closure to Update the Amplitude Chart on screen
    ///   - resultsShowingClosureAMPL: Closure to Update BPM Results
    func setReturnClosure(chartUpdateClosureFFT: @escaping () -> (), chartUpdateClosureAMPL: @escaping () -> (), resultsShowingClosureAMPL: @escaping (Double)->()) {
        updateChartFFT  = chartUpdateClosureFFT
        updateChartAMPL = chartUpdateClosureAMPL
        showResults     = resultsShowingClosureAMPL
    }
    
    ///Automatically called
    internal func startAudioEngine() {
        try? AudioKit.start()
        print("Audio engine started")
    }
    
    ///Automatically called
    internal func stopAudioEngine() {
        try? AudioKit.stop()
        print("Audio engine stopped")
    }
}
