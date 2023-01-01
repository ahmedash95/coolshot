//
//  MenuBarActions.swift
//  coolshot
//
//  Created by Ahmed on 28.12.22.
//

import Foundation
import SwiftUI

struct MenuBarActions {
    static func captureScreenAndOpenEditor() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.setActivationPolicy(.regular)
        
        guard let image = ScreenCapture().captureSelection() else {
            return
        }
                
        let view = EditorView(image: ImageModel(image: image))
        
        // open a new window with the editor view
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: min(max(1200, image.size.width), 1700), height: min(max(500, image.size.height), 1000)),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Editor")
        window.contentView = NSHostingView(rootView: view)
        window.miniwindowImage = NSImage(named: "windowIcon")
        window.makeKeyAndOrderFront(nil)
        window.styleMask.insert(.resizable)
        window.appearance = NSAppearance(named: .vibrantDark)
        window.backgroundColor = NSColor.black //.withAlphaComponent(0.5)
    }
    
    static func openPreferences() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.setActivationPolicy(.regular)
        
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Editor")
        window.contentView = NSHostingView(rootView: Preferences())
        window.miniwindowImage = NSImage(named: "windowIcon")
        window.makeKeyAndOrderFront(nil)
    }
}
