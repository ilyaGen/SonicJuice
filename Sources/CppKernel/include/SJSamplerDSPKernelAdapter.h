//
//  Header.h
//  
//
//  Created by Илья Амбражевич on 31.03.2021.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJSamplerDSPKernelAdapter : NSObject

@property (nonatomic) AUAudioFrameCount maximumFramesToRender;
@property (nonatomic, readonly) AUAudioUnitBus *inputBus;
@property (nonatomic, readonly) AUAudioUnitBus *outputBus;

- (void)setParameter:(AUParameter *)parameter value:(AUValue)value;
- (AUValue)valueForParameter:(AUParameter *)parameter;

- (void)allocateRenderResources;
- (void)deallocateRenderResources;
- (AUInternalRenderBlock)internalRenderBlock;

- (BOOL)shouldBypassEffect;
- (void)setShouldBypassEffect:(BOOL)bypass;

- (instancetype)init:(AVAudioPCMBuffer *)buffer;

@end

NS_ASSUME_NONNULL_END
