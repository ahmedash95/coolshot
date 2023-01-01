//
//  Base.swift
//  RapidSnap
//
//  Created by Ahmed on 01.01.23.
//

import Foundation
import SwiftUI

let EnabledShapes: [AppShape] = [
    AppShape(type: .none, systemImageName: "cursorarrow"),
    AppShape(type: .arrow, systemImageName: "arrow.up.right"),
    AppShape(type: .rectangle, systemImageName: "rectangle"),
]

enum ShapeType: String {
    case none = "none"
    case rectangle = "rectangle"
    case arrow = "arrow"
}

struct AppShape: Hashable {
    var type: ShapeType
    var systemImageName: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(systemImageName)
    }
}


struct ShapeDetails: Hashable {
    var type: ShapeType = .rectangle
    var width = 0.0
    var height = 0.0
    var start = CGPoint.zero
    var end = CGPoint.zero
    var color = Color.white
    var thinkness = 3.0
    var fill = false
    var rotation: Double = 0

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(start.x)
        hasher.combine(start.y)
    }
}
