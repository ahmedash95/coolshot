//
//  MenuBarActions.swift
//  coolshot
//
//  Created by Ahmed on 28.12.22.
//

import Foundation
import SwiftUI

struct MenuBarActions {
    static func requestScreenAccess() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: WelcomeScreen())
        window.makeKeyAndOrderFront(nil)
    }
    
    static func SelectFileAndOpenEditor() {
        let panel = NSOpenPanel()
        panel.title = "Select Image"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.canCreateDirectories = false
        panel.allowedContentTypes = [.jpeg,.png,.tiff,.image]
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            guard let image = NSImage(contentsOf: url) else { return }
            OpenEditor(model: ImageModel(image: image))
        }
    }
    
    
    static func copyFromClipboardAndOpenEditor() {
        let contents = NSPasteboard.general.readObjects(forClasses: [NSImage.self])
        let images = contents as! [NSImage]
        if images.count > 0 {
            guard let image = images.first else {
                return
            }
            OpenEditor(model: ImageModel(image: image))
        }
    }
    
    static func captureScreenAndOpenEditor() {
        guard let image = ScreenCapture().captureSelection() else {
            return
        }
                
        OpenEditor(model: ImageModel(image: image))
    }
    
    
    static func OpenEditor(model: ImageModel) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        let view = EditorView(image: model)
        
        // open a new window with the editor view
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: min(max(1200, model.image.size.width), 1700), height: min(max(500, model.image.size.height), 1000)),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        window.center()
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
        window.setFrameAutosaveName("Editor")
        window.contentView = NSHostingView(rootView: view)
        window.miniwindowImage = NSImage(named: "windowIcon")
        window.makeKeyAndOrderFront(nil)
        window.styleMask.insert(.resizable)
        window.appearance = NSAppearance(named: .vibrantDark)
        window.backgroundColor = NSColor.black //.withAlphaComponent(0.5)
    }
    
    static func openPreferences() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: Preferences())
        window.makeKeyAndOrderFront(nil)
    }
}
