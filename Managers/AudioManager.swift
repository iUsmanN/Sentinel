import AudioKit
import AudioKitUI

// Treat the conductor like a manager for the audio engine.
class AudioManager {
    
    // Singleton of the Conductor class to avoid multiple instances of the audio engine
    static let sharedInstance   = AudioManager()
    
    // Create instance variables
    var mic                     : AKMicrophone!
    var tracker                 : AKAmplitudeTracker!
    var boost                   : AKBooster!
    
    //Array to store amplitudes
    var averageArray            = [Double]()
    var micDataArray            = [Double]()
    
    //Amplification
    var ampFactor               = 6
    
    //Average
    var sum : Double            = 0
    
    //Closure to pass Arr
    var updateChart             : (() -> ())!
    var showResults             : (() -> ())!
    
    private init() {

        // Capture mic input
        mic = AKMicrophone()
        
        // Pull mic output into the tracker node.
        tracker = AKAmplitudeTracker(mic)
        
        //ADD ADDITIONAL NODES HERE
        
        // Assign the output to be the final audio output
        AudioKit.output = tracker
        
        // Start the AudioKit engine
        startAudioEngine()
        
        //Capture Values every 0.1s
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            //self.arr.append(self.tracker.amplitude)
            
            //Save amplified data to array2
            self.micDataArray.append(self.tracker.amplitude * self.ampFactor)
            
            //Save current average in array
            self.averageArray.append(self.getAverage(input: (self.getAverage(input: self.tracker.amplitude * self.ampFactor))))
        }
        
        //Stop Recording after 20s
        Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
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
}
