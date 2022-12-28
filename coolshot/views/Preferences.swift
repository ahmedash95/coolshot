//
//  Preferences.swift
//  coolshot
//
//  Created by Ahmed on 28.12.22.
//

import SwiftUI
import KeyboardShortcuts

struct Preferences: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Capture screen:", name: .coolshotCapture)
        }
    }
}

struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
    }
}
