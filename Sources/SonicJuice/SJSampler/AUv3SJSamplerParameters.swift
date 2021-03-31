//
//  AUv3SJSamplerParameters.swift
//  SJFramework
//
//  Created by Илья Амбражевич on 29.03.2021.
//


import Foundation

/// Manages the AUv3SJSampler  parameters.
class AUv3SJSamplerParameters {

    private enum AUv3FilterParam: AUParameterAddress {
        case pitch
    }

    /// Parameter to control playback pitch
    var pitchParam: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "pitch",
                                            name: "Pitch",
                                            address: AUv3FilterParam.pitch.rawValue,
                                            min: -12.0,
                                            max: 12.0,
                                            unit: .octaves,
                                            unitName: nil,
                                            flags: [.flag_IsReadable,
                                                    .flag_IsWritable,
                                                    .flag_CanRamp],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        // Set default value
        parameter.value = 0.0

        return parameter
    }()


    let parameterTree: AUParameterTree

    init(kernelAdapter: SJSamplerDSPKernelAdapter) {

        // Create the audio unit's tree of parameters
        parameterTree = AUParameterTree.createTree(withChildren: [pitchParam])

        // Closure observing all externally-generated parameter value changes.
        parameterTree.implementorValueObserver = { param, value in
            kernelAdapter.setParameter(param, value: value)
        }

        // Closure returning state of requested parameter.
        parameterTree.implementorValueProvider = { param in
            return kernelAdapter.value(for: param)
        }

        // Closure returning string representation of requested parameter value.
        parameterTree.implementorStringFromValueCallback = { param, value in
            switch param.address {
            case AUv3FilterParam.pitch.rawValue:
                return String(format: "%.f", value ?? param.value)
            default:
                return "?"
            }
        }
    }
    
    func setParameterValues(pitch: AUValue) {
        pitchParam.value = pitch
    }
}
