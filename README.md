# 🎤 Speech Transcriber

A native macOS app for real-time speech-to-text transcription using OpenAI Whisper, featuring a floating widget interface and global hotkey activation.

## ✨ Features

- **🚀 Native Swift Implementation**: No Python dependencies - pure Swift with SwiftWhisper
- **⌨️ Global Hotkey**: Press `⌘⇧S` to instantly show/hide the floating transcription widget
- **🎙️ Real-time Recording**: Visual waveform feedback during recording
- **⏱️ Smart Auto-stop**: Automatically stops after 5 or 10 seconds of silence (configurable)
- **🎯 Manual Controls**: Click record/stop buttons for full control
- **🧠 AI-Powered**: Uses OpenAI Whisper tiny model (74MB) for accurate transcription
- **📋 Copy to Clipboard**: One-click copying of transcribed text
- **⚙️ Customizable Settings**: Configure silence duration and auto-stop behavior
- **🎨 Floating UI**: Always-on-top widget that doesn't interfere with your workflow

## 🔧 Requirements

- macOS 13.0+
- Xcode 14.0+ (for building from source)

## 📦 Installation

### Option 1: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/olanigan/SpeechTranscriber.git
   cd SpeechTranscriber
   ```

2. Build the Swift package:
   ```bash
   swift build -c release
   ```

3. Run the app:
   ```bash
   .build/release/SpeechTranscriber
   ```

### Option 2: Download Pre-built Binary (Coming Soon)

Pre-built releases will be available in the [Releases](https://github.com/olanigan/SpeechTranscriber/releases) section.

## 📊 Technical Details

- **Model**: OpenAI Whisper Tiny (74MB) - bundled with the app
- **Framework**: SwiftWhisper (native Swift wrapper for whisper.cpp)
- **Architecture**: MVVM with Combine for reactive UI updates
- **Audio Format**: 16kHz PCM for optimal Whisper compatibility
- **Memory Usage**: ~200MB during operation
- **Dependencies**: Zero external runtime dependencies

## 🚀 Usage

### Quick Start
1. **Launch**: Run the app (it runs in the background)
2. **Activate**: Press `⌘⇧S` to show the floating widget
3. **Record**: Click the record button (🔴) or start speaking
4. **Transcribe**: Recording auto-stops after silence, or click stop (⏹️)
5. **Copy**: Click the copy button (📄) to copy transcription

### Interface Guide

```
┌─────────────────────────────────┐
│ 🔴 Ready          ⏹️ Stop/Copy │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ [Waveform visualization]    │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Transcription text appears  │ │
│ │ here...                     │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Settings

Access settings through the app menu:
- **Auto-stop on silence**: Enable/disable automatic recording stop
- **Silence duration**: Choose 5 or 10 seconds of silence before auto-stop

### Keyboard Shortcuts
- `⌘⇧S`: Toggle floating widget visibility

## 🏗️ Architecture

```
SpeechTranscriber/
├── SpeechTranscriberApp.swift      # App entry point & hotkey setup
├── AppDelegate.swift               # Window management & lifecycle
├── FloatingWidgetWindow.swift      # Custom floating NSWindow
├── SpeechTranscriberViewModel.swift # MVVM state management
├── WhisperTranscriber.swift        # SwiftWhisper integration
├── SettingsView.swift              # User preferences UI
└── Resources/
    └── whisper-tiny.bin           # Bundled Whisper model (74MB)
```

### Key Components

- **🎯 SwiftWhisper**: Native Swift wrapper for whisper.cpp (no Python!)
- **🎙️ AVFoundation**: Audio recording in 16kHz PCM format
- **⌨️ HotKey**: Global hotkey registration for instant activation
- **🎨 SwiftUI**: Modern reactive UI with Combine
- **📦 Swift Package Manager**: Zero-config dependency management

## 🔧 Troubleshooting

### Common Issues

- **Microphone Permission**: Grant access in System Settings → Privacy & Security → Microphone
- **Hotkey Conflicts**: Check if another app uses `⌘⇧S`
- **Build Failures**: Ensure Xcode 14.0+ and macOS 13.0+
- **Transcription Errors**: Check Console.app for detailed logs

### Debug Output
The app provides detailed console output during model loading:
```
whisper_model_load: model size = 73.54 MB
whisper_init_state: kv self size = 2.62 MB
Whisper model initialized successfully
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OpenAI Whisper](https://github.com/openai/whisper) - The amazing AI model
- [SwiftWhisper](https://github.com/exPHAT/SwiftWhisper) - Native Swift integration
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - C++ implementation
