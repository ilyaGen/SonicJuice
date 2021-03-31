//
//  SJSampler.swift
//  SJFramework
//
//  Created by Илья Амбражевич on 29.03.2021.
//

import Foundation
import AudioToolbox
import CoreAudioKit
import AVFoundation



// Controller object used to manage the interaction with the audio unit and its user interface.
public class SJSampler {

    /// The user-selected audio unit.
    private var audioUnit: AUv3SJSampler?
    
    public var avAudioUnit: AVAudioUnit?


    public var pitchValue: Float = 0.0 {
        didSet {
            pitchParameter.value = pitchValue
        }
    }
    
    public func start() {
        audioUnit?.shouldBypassEffect = false
    }

    public func stop() {
        audioUnit?.shouldBypassEffect = true
    }

    // The audio unit's filter cutoff frequency parameter object.
    private var pitchParameter: AUParameter!


    // A token for our registration to observe parameter value changes.
    private var parameterObserverToken: AUParameterObserverToken!

    // The AudioComponentDescription matching the AUv3FilterExtension Info.plist
    private var componentDescription: AudioComponentDescription = {

        // Ensure that AudioUnit type, subtype, and manufacturer match the extension's Info.plist values
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Generator
        componentDescription.componentSubType = 0x736d706c /*'smpl'*/
        componentDescription.componentManufacturer = 0x534a5746 /*'SJWF'*/
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0

        return componentDescription
    }()

    private let componentName = "SJFW: AUv3SJSampler"

    public init() {
        
        /*
         Register our `AUAudioUnit` subclass, `AUv3FilterDemo`, to make it able
         to be instantiated via its component description.

         Note that this registration is local to this process.
         */
        AUAudioUnit.registerSubclass(AUv3SJSampler.self,
                                     as: componentDescription,
                                     name: componentName,
                                     version: UInt32.max)

        AVAudioUnit.instantiate(with: componentDescription) { audioUnit, error in
            guard error == nil, let audioUnit = audioUnit else {
                fatalError("Could not instantiate audio unit: \(String(describing: error))")
            }
            self.audioUnit = audioUnit.auAudioUnit as? AUv3SJSampler
            self.connectParametersToControls()
            
            self.avAudioUnit = audioUnit
            
        }
    }

    /**
     Called after instantiating our audio unit, to find the AU's parameters and
     connect them to our controls.
     */
    private func connectParametersToControls() {

        guard let audioUnit = audioUnit else {
            fatalError("Couldn't locate AUv3SJSampler")
        }

        // Find our parameters by their identifiers.
        guard let parameterTree = audioUnit.parameterTree else {
            fatalError("AUv3SJSampler does not define any parameters.")
        }

        pitchParameter = parameterTree.value(forKey: "pitch") as? AUParameter

    }

    public func cleanup() {
        guard let parameterTree = audioUnit?.parameterTree else { return }
        parameterTree.removeParameterObserver(parameterObserverToken)
    }
}
