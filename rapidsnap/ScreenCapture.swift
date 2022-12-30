//
//  ScreenCapture.swift
//  ScreenCapture
//
//  Created by Jack P. on 11/12/2015.
//  Copyright © 2015 Jack P. All rights reserved.
//

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import AppKit

class ScreenCapture {
    func captureSelection() -> NSImage? {
        let uuid = UUID().uuidString
        let filePath = NSTemporaryDirectory() + "screenshot-\(uuid).png"
        
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r", filePath]
        task.launch()
        task.waitUntilExit()
        let status = task.terminationStatus

        if status == 0 {
            let image = NSImage(contentsOfFile: filePath)
            try? FileManager.default.removeItem(atPath: filePath)
            return image
        } else {
            return nil
        }
    }
}
