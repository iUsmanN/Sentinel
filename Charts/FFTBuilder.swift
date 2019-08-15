//
//  FFTBuilder.swift
//  AudioKit_Stethoscope
//
//  Created by Usman Nazir on 09/08/2019.
//  Copyright © 2019 Usman Nazir. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import AudioKitUI

protocol FFTBuilder { }

extension FFTBuilder {
    
    func getFFT(targetFrame: CGRect, inputSource: AKNode) -> UIView {
        
        let fftplot = AKNodeFFTPlot(inputSource, frame: targetFrame)
        fftplot.shouldFill = true
        fftplot.shouldMirror = false
        fftplot.shouldCenterYAxis = true
        fftplot.color = AKColor.white
        fftplot.backgroundColor = AKColor.darkGray
        fftplot.gain = 2
        
        return fftplot
    }
    
}
