import SwiftUI
import HotKey

@main
struct SpeechTranscriberApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var hotKey: HotKey?
    var floatingWindow: FloatingWidgetWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupHotKey()
        setupFloatingWindow()
    }
    
    private func setupHotKey() {
        hotKey = HotKey(key: .s, modifiers: [.command, .shift])
        hotKey?.keyDownHandler = {
            self.toggleFloatingWindow()
        }
    }
    
    private func setupFloatingWindow() {
        floatingWindow = FloatingWidgetWindow()
    }
    
    private func toggleFloatingWindow() {
        if floatingWindow?.isVisible == true {
            floatingWindow?.orderOut(nil)
        } else {
            floatingWindow?.makeKeyAndOrderFront(nil)
            floatingWindow?.center()
        }
    }
}
