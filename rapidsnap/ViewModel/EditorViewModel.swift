//
//  EditorViewModel.swift
//  coolshot
//
//  Created by Ahmed on 11.12.22.
//

import Foundation
import SwiftUI
import AppKit

class EditorViewModel {
    
    var screenCapture = ScreenCapture()
    
    let gradientObjects: [[Color]] = [
        [.orange, .red, .pink],
        [.purple, .indigo, .darkBlue],
        [.lightPink, .pink, .lightPurple],
        [.red, .orange, .yellow],
        [.lightBlue, .blue, .darkBlue],
        [.lightYellow, .yellow, .orange],
        [.orange, .purple, .yellow],
        [.red, .orange],
        [.yellow, .green],
        [.blue, .purple],
        [.pink, .white],
        [.green, .blue],
        [.purple, .pink],
        [.gray, .red],
        [.white],
        [.black],
    ]
    
    @MainActor func copyToClipboard(view: some View) {
        guard let output = self.getImageFromView(view: view) else {
            return
        }
        
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([output])
    }
    
    @MainActor func saveToFile(view: some View) {
        guard let output = self.getImageFromView(view: view) else {
            return
        }
        
        if let url = self.showSavePanel() {
            self.savePNG(path: url, image: output)
        }
    }
    
    @MainActor func getImageFromView(view: some View) -> NSImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        
        return renderer.nsImage!
    }
    
    func showSavePanel() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let coolshotString = "coolshot-" + dateFormatter.string(from: Date())

        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png,.jpeg]
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
}
