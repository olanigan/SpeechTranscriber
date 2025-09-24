import SwiftUI
import AVFoundation
import Combine

class SpeechTranscriberViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var transcription = ""
    @Published var audioLevel: Float = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioEngine: AVAudioEngine?
    private var whisperTranscriber: WhisperTranscriber?
    private var silenceTimer: Timer?
    private var recordingStartTime: Date?
    
    private let silenceThreshold: Float = 0.01
    @AppStorage("silenceDuration") private var silenceDuration: Double = 5.0
    @AppStorage("autoStopEnabled") private var autoStopEnabled: Bool = true
    
    init() {
        setupAudioSession()
        whisperTranscriber = WhisperTranscriber()
    }
    
    private func setupAudioSession() {
        // Audio session setup not needed on macOS
        // AVAudioSession is iOS-only
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000, // Record directly at 16kHz for Whisper
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            recordingStartTime = Date()
            startSilenceDetection()
            startAudioLevelMonitoring()
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        isRecording = false
        silenceTimer?.invalidate()
        audioEngine?.stop()
        
        // Start transcription
        if let audioURL = audioRecorder?.url {
            transcribeAudio(at: audioURL)
        }
    }
    
    private func startSilenceDetection() {
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            
            recorder.updateMeters()
            let averagePower = recorder.averagePower(forChannel: 0)
            let level = pow(10.0, averagePower / 20.0)
            
            if self.autoStopEnabled && level < self.silenceThreshold {
                if let startTime = self.recordingStartTime,
                   Date().timeIntervalSince(startTime) > self.silenceDuration {
                    self.stopRecording()
                }
            } else {
                self.recordingStartTime = Date() // Reset silence timer
            }
        }
    }
    
    private func startAudioLevelMonitoring() {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            guard let self = self else { return }
            
            let channelData = buffer.floatChannelData?[0]
            let channelDataCount = Int(buffer.frameLength)
            
            var sum: Float = 0.0
            for i in 0..<channelDataCount {
                sum += channelData![i] * channelData![i]
            }
            
            let rms = sqrt(sum / Float(channelDataCount))
            DispatchQueue.main.async {
                self.audioLevel = min(rms * 10, 1.0) // Normalize and cap
            }
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func transcribeAudio(at url: URL) {
        Task {
            do {
                let text = try await whisperTranscriber?.transcribe(audioURL: url) ?? ""
                DispatchQueue.main.async {
                    self.transcription = text.isEmpty ? "No speech detected" : text
                }
            } catch let error as WhisperError {
                let errorMessage: String
                switch error {
                case .notInitialized:
                    errorMessage = "Whisper model not initialized. Please wait and try again."
                case .transcriptionFailed(let details):
                    errorMessage = "Transcription failed: \(details)"
                case .audioConversionFailed(let details):
                    errorMessage = "Audio conversion failed: \(details)"
                }
                DispatchQueue.main.async {
                    self.transcription = errorMessage
                }
            } catch {
                DispatchQueue.main.async {
                    self.transcription = "Transcription failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func copyTranscription() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(transcription, forType: .string)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
