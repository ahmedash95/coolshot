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
        
        let image = EditorViewModel().takeScreenShot()
        let imageModel = ImageModel(image: image)
        // create an instance of the EditorView with the image object
        let editorView = EditorView().environmentObject(imageModel)
        // open a new window with the editor view
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Editor")
        window.contentView = NSHostingView(rootView: editorView)
        window.miniwindowImage = NSImage(named: "windowIcon")
        window.makeKeyAndOrderFront(nil)
    }
    
    static func openPreferences() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.setActivationPolicy(.regular)
        
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Editor")
        window.contentView = NSHostingView(rootView: Preferences())
        window.miniwindowImage = NSImage(named: "windowIcon")
        window.makeKeyAndOrderFront(nil)
    }
}
