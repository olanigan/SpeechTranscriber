import SwiftUI

class FloatingWidgetWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Speech Transcriber"
        self.level = .floating
        self.isReleasedWhenClosed = false
        self.contentView = NSHostingView(rootView: FloatingWidgetView())
        
        // Make window float above all other windows
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        
        // Remove from window menu
        self.isExcludedFromWindowsMenu = true
    }
}

struct FloatingWidgetView: View {
    @StateObject private var viewModel = SpeechTranscriberViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            // Recording status
            HStack {
                Circle()
                    .fill(viewModel.isRecording ? Color.red : Color.gray)
                    .frame(width: 12, height: 12)
                Text(viewModel.isRecording ? "Recording..." : "Ready")
                    .font(.headline)
            }
            
            // Voice modulation indicator
            if viewModel.isRecording {
                WaveformView(audioLevel: viewModel.audioLevel)
                    .frame(height: 40)
            }
            
            // Control buttons
            HStack(spacing: 20) {
                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                    } else {
                        viewModel.startRecording()
                    }
                }) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(viewModel.isRecording ? .red : .green)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    viewModel.copyTranscription()
                }) {
                    Image(systemName: "doc.on.doc")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.transcription.isEmpty)
            }
            
            // Transcription display
            ScrollView {
                Text(viewModel.transcription)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(height: 80)
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}

struct WaveformView: View {
    let audioLevel: Float
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<20) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.blue)
                        .frame(width: 4, height: geometry.size.height * CGFloat(min(audioLevel * 2, 1.0)))
                        .opacity(Double(index) / 20.0)
                }
            }
        }
    }
}
