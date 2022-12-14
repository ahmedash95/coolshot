//
//  Preferences.swift
//  coolshot
//
//  Created by Ahmed on 28.12.22.
//

import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin

struct Preferences: View {
    
    @State private var autoclose: Bool;
    
    private let storage = Storage.shared
    
    init() {
        self.autoclose = storage.value(.autoclose_on_copy, defaultValue: true) as! Bool
    }
    
    var body: some View {
        VStack {
            Image(nsImage: NSImage(named: "AppIcon")!)
                .padding(.bottom, 20)
            Text(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "")
                .padding(.bottom, 20)
            
            Divider().padding(5)
            
            Form {
                KeyboardShortcuts.Recorder("Capture screen:", name: .rapidSnapCapture)
            }.padding(20)
            
            Divider().padding(5)
            
            Form {
                
                Toggle("Close editor automatically on copy", isOn: $autoclose)
                    .pickerStyle(RadioGroupPickerStyle())
                    .onChange(of: self.autoclose, perform: { value in
                        storage.set(.autoclose_on_copy, value)
                    })
                
                LaunchAtLogin.Toggle()
            }
            
            Divider().padding(5)
            
            Button("Submit issue or feedback") {
                if let url = URL(string: "https://github.com/ahmedash95/rapidsnap-support/issues") {
                    NSWorkspace.shared.open(url)
                }
            }
        }.padding([.bottom,.top], 50)
    }
}

struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
    }
}
