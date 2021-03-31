//
//  Header.h
//  
//
//  Created by Илья Амбражевич on 31.03.2021.
//

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility code to manage scheduled parameters in an audio unit implementation.
*/

#ifndef DSPKernel_h
#define DSPKernel_h


#import <AudioToolbox/AudioToolbox.h>
#import <algorithm>

static inline float convertBadValuesToZero(float x) {
    /*
     Eliminate denormals, not-a-numbers, and infinities.
     Denormals will fail the first test (absx > 1e-15), infinities will fail
     the second test (absx < 1e15), and NaNs will fail both tests. Zero will
     also fail both tests, but since it will get set to zero that is OK.
     */

    float absx = fabs(x);

    if (absx > 1e-15 && absx < 1e15) {
        return x;
    }

    return 0.0;
}

static inline double squared(double x) {
    return x * x;
}


template <typename T>
T clamp(T input, T low, T high) {
    return std::min(std::max(input, low), high);
}

// Put your DSP code into a subclass of DSPKernel.
class DSPKernel {
public:
    virtual void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) = 0;
    virtual void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) = 0;

    // Override to handle MIDI events.
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) {}

    void processWithEvents(AudioTimeStamp const* timestamp, AUAudioFrameCount frameCount, AURenderEvent const* events, AUMIDIOutputEventBlock midiOut);

    AUAudioFrameCount maximumFramesToRender() const {
        return maxFramesToRender;
    }

    void setMaximumFramesToRender(const AUAudioFrameCount &maxFrames) {
        maxFramesToRender = maxFrames;
    }

private:
    void handleOneEvent(AURenderEvent const* event);
    void performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const*& event, AUMIDIOutputEventBlock midiOut);

    AUAudioFrameCount maxFramesToRender = 512;
};

#endif /* DSPKernel_h */

