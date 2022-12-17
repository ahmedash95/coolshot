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
    func screenshotWindowAndSuccess() -> Bool {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-ci"]
        task.launch()
        task.waitUntilExit()
        let status = task.terminationStatus
        return status == 0
    }

    func getImageFromPasteboard() -> NSImage {
        let pasteboard = NSPasteboard.general
        guard pasteboard.canReadItem(withDataConformingToTypes:
            NSImage.imageTypes) else { return NSImage() }
        guard let image = NSImage(pasteboard: pasteboard) else { return
            NSImage() }
        return image
    }
}
