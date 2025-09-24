import SwiftUI

struct SettingsView: View {
    @AppStorage("silenceDuration") private var silenceDuration: Double = 5.0
    @AppStorage("autoStopEnabled") private var autoStopEnabled: Bool = true
    
    var body: some View {
        Form {
            Section(header: Text("Recording Settings")) {
                Toggle("Auto-stop on silence", isOn: $autoStopEnabled)
                
                if autoStopEnabled {
                    Picker("Silence duration", selection: $silenceDuration) {
                        Text("5 seconds").tag(5.0)
                        Text("10 seconds").tag(10.0)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            Section(header: Text("About")) {
                Text("Speech Transcriber v1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Press ⌘⇧S to activate the floating widget")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}
