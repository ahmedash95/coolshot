//
//  ContentView.swift
//  coolshot
//
//  Created by Ahmed on 05.12.22.
//

import SwiftUI
import AppKit
import UserNotifications

struct Line {
    var points = [CGPoint]()
    var color: Color = .red
    var lineWidth: Double = 1.0
}

struct EditorView: View {
    @State private var image = NSImage(named: "out")
    @State private var selectedGradientIndex = 0
    
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    @State private var indexStack: [Int] = []
    @State private var thickness: Double = 1.0
    @State private var isDragging: Bool = false


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
            
            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                }
            }.gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged({ value in
                    if isDragging == false {
                        self.indexStack.append(self.lines.count - 1)
                        self.isDragging = true
                    }
                    let newPoint = value.location
                    currentLine.points.append(newPoint)
                    self.lines.append(currentLine)
                  })
                .onEnded({ value in
                    self.lines.append(currentLine)
                    self.currentLine = Line(points: [], color: currentLine.color, lineWidth: thickness)
                    self.isDragging = false
                })
            )
        }
    }
    
    var body: some View {
        // Buttons
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
            
            Button("Undo ⌘Z") {
                if indexStack.count == 0 {
                    return
                }
                
                let targetIndex = indexStack.popLast()
                while self.lines.count > targetIndex! {
                    if self.lines.count == 0 {
                        break
                    }
                    self.lines.removeLast()
                }
            }.keyboardShortcut("Z")
            
        }.padding([.top, .bottom], 10)

        editorView
        
        // Canvas controller
        HStack {
            Slider(value: $thickness, in: 1...20) {
                Text("Thickness")
            }.frame(maxWidth: 200)
                .onChange(of: thickness) { newThickness in
                    currentLine.lineWidth = newThickness
                }
            Divider()
            ColorPickerView(selectedColor: $currentLine.color)
                .onChange(of: currentLine.color) { newColor in
                    print(newColor)
                    currentLine.color = newColor
            }
        }.frame(height: 50)
        
        // Backgrounds
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

struct Arrow: Shape {
    var length: CGFloat = 100

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let constrainedLength = min(max(length, 0), 200)

        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - constrainedLength, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))

        return path
    }
}
