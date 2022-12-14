//
//  ContentView.swift
//  coolshot
//
//  Created by Ahmed on 05.12.22.
//

import SwiftUI
import AppKit
import UserNotifications


struct EditorView: View {
    @State private var image = NSImage(named: "out")
    @State private var selectedGradientIndex = 0


    var editorViewModel = EditorViewModel()
    
    var editorView: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: editorViewModel.gradientObjects[selectedGradientIndex]),
               startPoint: .topLeading,
               endPoint: .bottomTrailing)


            Image(nsImage: image!)
                .resizable()
                .scaledToFit()
                .cornerRadius(20)
                .padding(50)
        }
    }
    
    var body: some View {
        HStack {
            Button("Take") {
                image = editorViewModel.takeScreenShot()
            }
            
            Button("Copy ⌘C") {
                editorViewModel.copyToClipboard(view: editorView)
            }.keyboardShortcut("C")
            
            Button("Save ⌘S") {
                editorViewModel.saveToFile(view: editorView)
            }.keyboardShortcut("S")
            
        }.padding([.top, .bottom], 10)

        editorView
        
        HStack {
            ForEach(0..<editorViewModel.gradientObjects.count, id: \.self) { i in
                let go = editorViewModel.gradientObjects[i]
                LinearGradient(
                    gradient: Gradient(colors: go),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                .gesture(TapGesture().onEnded{
                    selectedGradientIndex = i
                })
                .frame(width: 50, height: 50)
            }
        }.padding(10)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
