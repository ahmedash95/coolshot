//
//  coolshotApp.swift
//  coolshot
//
//  Created by Ahmed on 05.12.22.
//

import SwiftUI
import Security
import UserNotifications

class ImageModel: ObservableObject {
    @Published var image: NSImage

    init(image: NSImage) {
        self.image = image
    }
}

@main
struct coolshotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("1", systemImage: "1.circle") {
            Button("Capture area") {
                let image = EditorViewModel().takeScreenShot()
                let imageModel = ImageModel(image: image)
                // create an instance of the EditorView with the image object
                let editorView = EditorView().environmentObject(imageModel)
                // open a new window with the editor view
                let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                    backing: .buffered, defer: false)
                window.center()
                window.setFrameAutosaveName("Editor")
                window.contentView = NSHostingView(rootView: editorView)
                window.miniwindowImage = NSImage(named: "windowIcon")
                window.makeKeyAndOrderFront(nil)
            }
            Button("Test Window") {
                NSApp.setActivationPolicy(.regular)
                if !NSApplication.shared.isRunning {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
                let editorView = EditorView().environmentObject(ImageModel(image: NSImage(named: "out")!))
                // open a new window with the editor view
                let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                    backing: .buffered, defer: false)
                window.center()
                window.setFrameAutosaveName("Editor")
                window.contentView = NSHostingView(rootView: editorView)
                window.miniwindowImage = NSImage(named: "windowIcon")
                window.makeKeyAndOrderFront(nil)
            }
            Divider()
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


class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { (status, _) in }
        NSApp.setActivationPolicy(.accessory)
    }
}
