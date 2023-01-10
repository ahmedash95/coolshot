//
//  Image.swift
//  RapidSnap
//
//  Created by Ahmed on 11.01.23.
//

import SwiftUI


extension NSImage {
    public func getEdgeColor() -> Color {
        if let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            if let dataProvider = cgImage.dataProvider, let pixelData = dataProvider.data, let pixels = CFDataGetBytePtr(pixelData) {
                // Get the first pixel of the image
                let pixelOffset = 0
                let r = pixels[pixelOffset]
                let g = pixels[pixelOffset + 1]
                let b = pixels[pixelOffset + 2]
                let a = pixels[pixelOffset + 3]
                
                return Color(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, opacity: Double(a) / 255.0)
            } else {
                return Color.white
            }
        } else {
            return Color.white
        }
    }
}
