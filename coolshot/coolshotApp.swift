//
//  coolshotApp.swift
//  coolshot
//
//  Created by Ahmed on 05.12.22.
//

import SwiftUI
import Security

@main
struct coolshotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Launched")
    }
}
