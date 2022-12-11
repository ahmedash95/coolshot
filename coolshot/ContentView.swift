//
//  ContentView.swift
//  coolshot
//
//  Created by Ahmed on 05.12.22.
//

import SwiftUI
import AppKit


struct ContentView: View {
    let gradientObjects: [[Color]] = [
        [.red, .green, .blue],
        [.orange, .purple, .yellow],
        [.pink, .gray, .black],
        [.red, .orange],
        [.yellow, .green],
        [.blue, .purple],
        [.pink, .white],
        [.black, .gray],
        [.red, .yellow],
        [.green, .blue],
        [.purple, .pink],
        [.white, .black],
        [.gray, .red],
        [.white, .white],
        [.black, .black],
    ]
    
    @State private var image = NSImage(named: "out")
    @State private var selectedGradientIndex = 0

    var screenCapture = ScreenCapture()
    
    var editorView: some View {
        ZStack {
            LinearGradient(
               gradient: Gradient(colors: gradientObjects[selectedGradientIndex]),
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
                if screenCapture.screenshotWindowAndSuccess() {
                    image = screenCapture.getImageFromPasteboard()
                }
            }
            
            Button("Copy") {
                let renderer = ImageRenderer(content: editorView)
                renderer.scale = 2.0
                guard let output = renderer.nsImage else { return }

                
                let pb = NSPasteboard.general
                pb.clearContents()
                pb.writeObjects([output])
            }
            
            Button("Save") {
                let renderer = ImageRenderer(content: editorView)
                renderer.scale = 2.0
                guard let output = renderer.nsImage else { return }

                if let url = showSavePanel() {
                    savePNG(path: url, image: output)
                }
            }
        }.padding([.top, .bottom], 10)

        editorView
        
        HStack {
            ForEach(0..<gradientObjects.count, id: \.self) { i in
                let go = gradientObjects[i]
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

struct GradientObject {
    let color1: Color
    let color2: Color
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



func showSavePanel() -> URL? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
    let coolshotString = "coolshot-" + dateFormatter.string(from: Date())

    
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.png]
    savePanel.canCreateDirectories = true
    savePanel.isExtensionHidden = false
    savePanel.title = "Save your image"
    savePanel.message = "Choose a folder and a name to store the image."
    savePanel.nameFieldLabel = "Image file name:"
    savePanel.nameFieldStringValue = coolshotString
    
    let response = savePanel.runModal()
    return response == .OK ? savePanel.url : nil
}

func savePNG(path: URL, image: NSImage) {
    let imageRepresentation = NSBitmapImageRep(data: image.tiffRepresentation!)
    let pngData = imageRepresentation?.representation(using: .png, properties: [:])
    do {
        try pngData!.write(to: path)
    } catch {
        print(error)
    }
}
