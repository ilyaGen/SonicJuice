//
//  SJSamplerDSPKernelAdapter.cpp
//  SJFramework
//
//  Created by Илья Амбражевич on 29.03.2021.
//

#import <AVFoundation/AVFoundation.h>
#import "SJSamplerDSPKernel.h"
#import "BufferedAudioBus.h"
#import "SJSamplerDSPKernelAdapter.h"

@implementation SJSamplerDSPKernelAdapter {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    SJSamplerDSPKernel  _kernel;
    BufferedInputBus _inputBus;
    AVAudioPCMBuffer* _pcmBuffer;
}

- (instancetype)init:(AVAudioPCMBuffer *) buffer {

    if (self = [super init]) {
        AVAudioFormat *format = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100 channels:2];
        // Create a DSP kernel to handle the signal processing.
        
        _kernel.init(format.channelCount, format.sampleRate, buffer);
        _pcmBuffer = buffer;
        
        _kernel.setParameter(0, 0);

        // Create the input and output busses.
        _inputBus.init(format, 8);
        _outputBus = [[AUAudioUnitBus alloc] initWithFormat:format error:nil];
    }
    return self;
}

- (AUAudioUnitBus *)inputBus {
    return _inputBus.bus;
}

- (void)setParameter:(AUParameter *)parameter value:(AUValue)value {
    _kernel.setParameter(parameter.address, value);
}

- (AUValue)valueForParameter:(AUParameter *)parameter {
    return _kernel.getParameter(parameter.address);
}

- (AUAudioFrameCount)maximumFramesToRender {
    return _kernel.maximumFramesToRender();
}

- (void)setMaximumFramesToRender:(AUAudioFrameCount)maximumFramesToRender {
    _kernel.setMaximumFramesToRender(maximumFramesToRender);
}

- (BOOL)shouldBypassEffect {
    return _kernel.isBypassed();
}

- (void)setShouldBypassEffect:(BOOL)bypass {
    _kernel.setBypass(bypass);
}


- (void)allocateRenderResources {
    _inputBus.allocateRenderResources(self.maximumFramesToRender);
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate, _pcmBuffer);
    _kernel.reset();
}

- (void)deallocateRenderResources {
    _inputBus.deallocateRenderResources();
    // processWithEvents(timestamp, frameCount, realtimeEventListHead, nil /* MIDIOutEventBlock */);
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Subclassers must provide a AUInternalRenderBlock (via a getter) to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    // Specify captured objects are mutable.
    __block SJSamplerDSPKernel *state = &_kernel;

    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {

        if (frameCount > state->maximumFramesToRender()) {
            return kAudioUnitErr_TooManyFramesToProcess;
        }
        
        
        // If passed null output buffer pointers, process in-place in the input buffer.
        AudioBufferList *outAudioBufferList = outputData;
//        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
//            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
//                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
//            }
//        }

        state->setBuffers(outAudioBufferList);
        
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead, nil /* MIDIOutEventBlock */);
        
        return noErr;
    };
}


@end
