import XCTest
@testable import SonicJuice

final class SonicJuiceTests: XCTestCase {

    
    
    
    func testAudio() {
        
        
        let url = Bundle.module.url(forResource: "test", withExtension: "wav", subdirectory: "Resources")!
        
        let file = try! AVAudioFile(forReading: url)
        
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)!
        
        let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
        
        try! file.read(into: pcmBuffer, frameCount: AVAudioFrameCount(file.length))
        
        
        let sampler = SJSampler()
        
        sampler.loadPCMBuffer(pcmBuffer)
        
    }
    

    static var allTests = [
        ("testAudio", testAudio),
    ]
}
