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
    @Published var width: CGFloat
    @Published var height: CGFloat
    

    init(image: NSImage) {
        self.image = image
        self.width = image.size.width
        self.height = image.size.height
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
        if let name = KeyboardShortcuts.getShortcut(for: .rapidSnapCapture) {
            return " (\(name))"
        }
        
        return ""
    }
    
    var body: some Scene {
        MenuBarExtra("CoolShot", systemImage: "camera.on.rectangle") {
            Button("Capture area\(shortcutName)") {
                MenuBarActions.captureScreenAndOpenEditor()
            }.disabled(!CGPreflightScreenCaptureAccess())
            
            if !CGPreflightScreenCaptureAccess() {
                Button("Grant recording permissions to capture") {
                    CGRequestScreenCaptureAccess()
                }
            }
            
            Button("Open from file") {
                MenuBarActions.SelectFileAndOpenEditor()
            }
            
            Button("Open from clipboard") {
                MenuBarActions.copyFromClipboardAndOpenEditor()
            }

            Divider()
            Button("Preferences") {
                MenuBarActions.openPreferences()
            }

            if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
                Button("About \(appName)") {
                    NSApplication.shared.orderFrontStandardAboutPanel()
                }
            }

            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
        .commands {
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .undoRedo) { }
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    init() {
        KeyboardShortcuts.onKeyUp(for: .rapidSnapCapture) {
            MenuBarActions.captureScreenAndOpenEditor()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let hasScreenAccess = CGPreflightScreenCaptureAccess();
        if (!hasScreenAccess) {
            MenuBarActions.requestScreenAccess()
        }
    }
}
