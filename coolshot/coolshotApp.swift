//
//  coolshotApp.swift
//  coolshot
//
//  Created by Ahmed on 05.12.22.
//

import SwiftUI
import Security
import UserNotifications
import KeyboardShortcuts

class ImageModel: ObservableObject {
    @Published var image: NSImage

    init(image: NSImage) {
        self.image = image
    }
}

class ClosableWindow: NSWindow {
    override func close() {
        self.orderOut(NSApp)
        if NSApp.windows.count == 2 { // 2 because menubar is a window
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

@main
struct coolshotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var appState = AppState()
    
    var shortcutName: String {
        if let name = KeyboardShortcuts.getShortcut(for: .coolshotCapture) {
            return " (\(name))"
        }
        
        return ""
    }
    
    var body: some Scene {
        MenuBarExtra("CoolShot", systemImage: "camera.on.rectangle") {
            Button("Capture area\(shortcutName)") {
                MenuBarActions.captureScreenAndOpenEditor()
            }
            Divider()
            Button("Preferences") {
                MenuBarActions.openPreferences()
            }
            Button("About CoolShot") {
                NSApplication.shared.orderFrontStandardAboutPanel()
            }
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }.menuBarExtraStyle(.menu)
    }
}

@MainActor
final class AppState: ObservableObject {
    init() {
        KeyboardShortcuts.onKeyUp(for: .coolshotCapture) {
            MenuBarActions.captureScreenAndOpenEditor()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { (status, _) in }
        NSApp.setActivationPolicy(.accessory)
    }
}
