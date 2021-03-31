//
//  Header.h
//  
//
//  Created by Илья Амбражевич on 31.03.2021.
//

#ifndef SJSamplerDSPKernel_h
#define SJSamplerDSPKernel_h

#import "DSPKernel.h"
#import <vector>


/*
 FilterDSPKernel
 Performs our filter signal processing.
 As a non-ObjC class, this is safe to use from render thread.
 */
class SJSamplerDSPKernel : public DSPKernel {
    
public:
    // MARK: Types


    // MARK: Member Functions

    SJSamplerDSPKernel() : pitch(0) {}

    void init(int channelCount, double inSampleRate, AVAudioPCMBuffer* buffer) {
        //channelStates.resize(channelCount);
        
        chanCount = channelCount;
        
        sampleRate = float(inSampleRate);
        nyquist = 0.5 * sampleRate;
        inverseNyquist = 1.0 / nyquist;
        dezipperRampDuration = (AUAudioFrameCount)floor(0.02 * sampleRate);
        
        
        pcmBuffer = buffer;
    }

    void reset() {
//        for (FilterState& state : channelStates) {
//            state.clear();
//        }
    }

    bool isBypassed() {
        return bypassed;
    }

    void setBypass(bool shouldBypass) {
        bypassed = shouldBypass;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            default: pitch = value;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            default: return pitch;
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            default: pitch = value;
        }
    }

    void setBuffers(AudioBufferList* outBufferList) {
        //inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        //if (bypassed) {
            // Pass the samples through
            int channelCount = chanCount;
        
        
            for (int channel = 0; channel < channelCount; ++channel) {
//                if (inBufferListPtr->mBuffers[channel].mData ==  outBufferListPtr->mBuffers[channel].mData) {
//                    continue;
//                }
                for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                    int frameOffset = int(frameIndex + bufferOffset);
                    
                    float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                    value = cosf(float(frameOffset) / 100);
                    
                    *out = value;
                }
            }
        //}
    }

    // MARK: Member Variables

private:
    //std::vector<FilterState> channelStates;
    int chanCount;
    
    float value = 0;

    float sampleRate = 44100.0;
    float nyquist = 0.5 * sampleRate;
    float inverseNyquist = 1.0 / nyquist;
    AUAudioFrameCount dezipperRampDuration;

    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;

    bool bypassed = false;

public:
    // Parameters.
    AUValue pitch;
    
    AVAudioPCMBuffer* pcmBuffer;// = nullptr;
};

#endif /* FilterDSPKernel_hpp */
