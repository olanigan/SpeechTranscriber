import Foundation
import SwiftWhisper
import AVFoundation

class WhisperTranscriber {
    private var whisper: Whisper?
    private var isInitialized = false

    init() {
        Task {
            await initializeWhisper()
        }
    }

    private func initializeWhisper() async {
        do {
            // Try to load the model data directly from the file system
            // In Swift packages, Bundle.main.url(forResource:) doesn't work for package resources
            let modelData = try loadModelData()
            whisper = Whisper(fromData: modelData)
            isInitialized = true
            print("Whisper model initialized successfully")
        } catch {
            print("Failed to initialize Whisper model: \(error)")
        }
    }

    private func loadModelData() throws -> Data {
        // Get the executable path and look for the model in the Resources directory
        let executableURL = Bundle.main.executableURL ?? URL(fileURLWithPath: CommandLine.arguments[0])
        let executableDir = executableURL.deletingLastPathComponent()

        // Try different possible locations for the model file
        let possiblePaths = [
            executableDir.appendingPathComponent("whisper-tiny.bin"),
            executableDir.appendingPathComponent("../Resources/whisper-tiny.bin"),
            Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/whisper-tiny.bin") // macOS app bundle
        ]

        for modelURL in possiblePaths {
            if FileManager.default.fileExists(atPath: modelURL.path) {
                print("Found model at: \(modelURL.path)")
                return try Data(contentsOf: modelURL)
            }
        }

        // If none of the above work, try to find it relative to the current working directory
        let cwdModelURL = URL(fileURLWithPath: "Sources/SpeechTranscriber/Resources/whisper-tiny.bin")
        if FileManager.default.fileExists(atPath: cwdModelURL.path) {
            print("Found model at: \(cwdModelURL.path)")
            return try Data(contentsOf: cwdModelURL)
        }

        throw WhisperError.audioConversionFailed("Could not find whisper-tiny.bin model file in any expected location")
    }

    func transcribe(audioURL: URL) async throws -> String {
        guard isInitialized, let whisper = whisper else {
            throw WhisperError.notInitialized
        }

        // Convert audio file to 16kHz PCM format required by Whisper
        let audioFrames = try await convertAudioToPCM(audioURL: audioURL)

        // Transcribe the audio
        let segments = try await whisper.transcribe(audioFrames: audioFrames)

        // Combine all segment text
        let transcription = segments.map { $0.text }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)

        return transcription
    }

    private func convertAudioToPCM(audioURL: URL) async throws -> [Float] {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let pcmFloats = try await self.convertAudioFileToPCMArray(fileURL: audioURL)
                    continuation.resume(returning: pcmFloats)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func convertAudioFileToPCMArray(fileURL: URL) async throws -> [Float] {
        // Read the audio file
        let audioFile = try AVAudioFile(forReading: fileURL)

        // Check if it's already in the right format (16kHz, 1 channel, PCM)
        let format = audioFile.processingFormat
        if format.sampleRate == 16000 && format.channelCount == 1 && format.isInterleaved == false {
            // File is already in correct format, just read the samples
            let frameCount = AVAudioFrameCount(audioFile.length)
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!

            try audioFile.read(into: buffer)

            guard let floatChannelData = buffer.floatChannelData else {
                throw WhisperError.audioConversionFailed("Could not get float channel data")
            }

            let channelData = floatChannelData[0]
            let frameLength = Int(buffer.frameLength)

            var pcmFloats: [Float] = []
            pcmFloats.reserveCapacity(frameLength)

            for i in 0..<frameLength {
                pcmFloats.append(channelData[i])
            }

            return pcmFloats
        } else {
            // Need to convert - for now, return empty array
            print("Audio format conversion needed but not implemented")
            return []
        }
    }
}

enum WhisperError: Error {
    case notInitialized
    case transcriptionFailed(String)
    case audioConversionFailed(String)
}
