//
//  WelcomeScreen.swift
//  RapidSnap
//
//  Created by Ahmed on 01.01.23.
//

import SwiftUI

struct WelcomeScreen: View {
    var body: some View {
        VStack {
            Image(nsImage: NSImage(named: "AppIcon")!)
                .padding(.bottom, 20)
            Text(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "")
                .padding(.bottom, 20)
            
            Divider().padding(5)
            
            Text("RapidSnap needs ScreenRecording permissions to work")
            Button("Open ScreenRecording system panel") {
                CGRequestScreenCaptureAccess()
            }
        }.padding([.bottom,.top], 50)
    }
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen()
    }
}
