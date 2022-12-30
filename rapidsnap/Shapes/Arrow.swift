//
//  Arrow.swift
//  coolshot
//
//  Created by Ahmed on 19.12.22.
//

import Foundation
import SwiftUI


struct Arrow: Shape {
    var start: CGPoint
    var end: CGPoint
    
    struct Polygon: Shape {
        var points: [CGPoint]
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            if points.count > 0 {
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
                path.closeSubpath()
            }
            return path
        }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: start)
            path.addLine(to: end)
            
            let angle = atan2(end.y - start.y, end.x - start.x)
            let arrowLength: CGFloat = 20
            let arrowWidth: CGFloat = 15
            let arrowHead = Polygon(points:
                [
                    CGPoint(x: 0, y: arrowWidth / 2),
                    CGPoint(x: arrowLength, y: 0),
                    CGPoint(x: 0, y: -arrowWidth / 2),
                    CGPoint(x: 0, y: arrowWidth / 2)
                ]
            )
            let arrowTransform = CGAffineTransform(translationX: end.x, y: end.y)
                .rotated(by: angle)
            path.addPath(arrowHead.path(in: .zero).applying(arrowTransform))
        }
    }
}
