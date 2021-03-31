//
//  AUv3SJSampler.swift
//  SJFramework
//
//  Created by Илья Амбражевич on 29.03.2021.
//


import Foundation
import AudioToolbox
import AVFoundation
import CoreAudioKit

@_exported import CppKernel

fileprivate extension AUAudioUnitPreset {
    convenience init(number: Int, name: String) {
        self.init()
        self.number = number
        self.name = name
    }
}

public class AUv3SJSampler: AUAudioUnit {

    private let parameters: AUv3SJSamplerParameters
    private let kernelAdapter: SJSamplerDSPKernelAdapter

    lazy private var inputBusArray: AUAudioUnitBusArray = {
        AUAudioUnitBusArray(audioUnit: self,
                            busType: .input,
                            busses: [kernelAdapter.inputBus])
    }()

    lazy private var outputBusArray: AUAudioUnitBusArray = {
        AUAudioUnitBusArray(audioUnit: self,
                            busType: .output,
                            busses: [kernelAdapter.outputBus])
    }()

    /// The filter's input busses
    public override var inputBusses: AUAudioUnitBusArray {
        return inputBusArray
    }

    /// The filter's output busses
    public override var outputBusses: AUAudioUnitBusArray {
        return outputBusArray
    }
    
    /// The tree of parameters provided by this AU.
    public override var parameterTree: AUParameterTree? {
        get { return parameters.parameterTree }
        set { /* The sample doesn't allow this property to be modified. */ }
    }
    
    

    private let defaultPitch: AUValue = 0

    /// The currently selected preset.
    public override var currentPreset: AUAudioUnitPreset? {
        get { AUAudioUnitPreset(number: 0, name: "Default") }
        set { parameters.setParameterValues(pitch: defaultPitch) }
    }
    
    /// Indicates that this Audio Unit supports persisting user presets.
    public override var supportsUserPresets: Bool {
        return false
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {

        // Create adapter to communicate to underlying C++ DSP code
        let url = Bundle.main.url(forResource: "LOOP", withExtension: "wav")!
        
        let file = try! AVAudioFile(forReading: url)
        
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)!
        
        let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
        
        try file.read(into: pcmBuffer, frameCount: AVAudioFrameCount(file.length))
        
        kernelAdapter = SJSamplerDSPKernelAdapter(pcmBuffer)
        
        // Create parameters object to control pitch
        parameters = AUv3SJSamplerParameters(kernelAdapter: kernelAdapter)

        // Init super class
        try super.init(componentDescription: componentDescription, options: options)

        // Log component description values
        log(componentDescription)
        
    }

    private func log(_ acd: AudioComponentDescription) {
        let info = ProcessInfo.processInfo
        print("\(Date.init()) \(info.processName)[\(info.processIdentifier)]")
        let message = "    AUv3SJSampler (type: \(acd.componentType.stringValue), subtype: \(acd.componentSubType.stringValue), man: \(acd.componentManufacturer.stringValue))\n"
        print(message)
    }

    public override var maximumFramesToRender: AUAudioFrameCount {
        get {
            return kernelAdapter.maximumFramesToRender
        }
        set {
            if !renderResourcesAllocated {
                kernelAdapter.maximumFramesToRender = newValue
            }
        }
    }

    public override func allocateRenderResources() throws {
        if kernelAdapter.outputBus.format.channelCount != kernelAdapter.inputBus.format.channelCount {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(kAudioUnitErr_FailedInitialization), userInfo: nil)
        }
        try super.allocateRenderResources()
        kernelAdapter.allocateRenderResources()
    }

    public override func deallocateRenderResources() {
        super.deallocateRenderResources()
        kernelAdapter.deallocateRenderResources()
    }

    public override var internalRenderBlock: AUInternalRenderBlock {
        return kernelAdapter.internalRenderBlock()
    }

    // Boolean indicating that this AU can process the input audio in-place
    // in the input buffer, without requiring a separate output buffer.
    public override var canProcessInPlace: Bool {
        return true
    }
    
    public override var shouldBypassEffect: Bool {
        get {
            kernelAdapter.shouldBypassEffect()
        }
        set {
            kernelAdapter.setShouldBypassEffect(newValue)
        }
    }
}

