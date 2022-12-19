//
//  ContentView.swift
//  coolshot
//
//  Created by Ahmed on 05.12.22.
//

import SwiftUI
import AppKit
import UserNotifications
import Cocoa

enum ShapeType: String {
    case rectangle = "rectangle"
    case arrow = "arrow"
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


struct EditorView: View {
    @State private var image = NSImage(named: "out")
    @State private var selectedGradientIndex = 0
    
    @State private var thickness: Double = 3.0
    @State private var selectedColor: Color = .white
    @State private var shapeFill = false
    @State private var isDragging: Bool = false
    @State private var shapeType: ShapeType = .rectangle
    
    var editorViewModel = EditorViewModel()
    
    @State private var shapes: [ShapeDetails] = []
    @State private var currentShape: ShapeDetails = ShapeDetails()
    
    var editorView: some View {
        ZStack(alignment: .topLeading) {
            
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: editorViewModel.gradientObjects[selectedGradientIndex]),
                   startPoint: .topLeading,
                   endPoint: .bottomTrailing)
                
                Image(nsImage: image!)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .padding(20)
            }
            
            
            ForEach(shapes.filter{ $0.type == .rectangle }, id: \.self) { shape in
                Rectangle()
                    .fill(shape.fill ? shape.color : Color.clear)
                    .frame(width: shape.width, height: shape.height)
                    .border(shape.color, width: shape.thinkness)
                    .offset(x: shape.start.x, y: shape.start.y)
                    .scaledToFit()
            }
            
            ForEach(shapes.filter{ $0.type == .arrow }, id: \.self) { shape in
                Arrow(
                    start: shape.start,
                    end: shape.end
                )
                .stroke(shape.color, lineWidth: shape.thinkness)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ value in
                let startPoint = value.startLocation
                var endPoint = value.location
                
                if isDragging == false {
                    isDragging = true
                    self.currentShape = ShapeDetails(
                        type: self.shapeType,
                        width: 1,
                        height: 1,
                        start: startPoint,
                        end: startPoint,
                        color: self.selectedColor,
                        thinkness: self.thickness,
                        fill: self.shapeFill
                    )
                    shapes.append(currentShape)
                } else {
                    if self.shapeType == .arrow {
                        self.currentShape.end = endPoint
                    } else {
                        endPoint = value.location
                        let width = abs(endPoint.x - startPoint.x)
                        let height = abs(endPoint.y - startPoint.y)
                        self.currentShape.start = CGPoint(
                            x: min(startPoint.x, endPoint.x),
                            y: min(startPoint.y, endPoint.y)
                        )
                        self.currentShape.width = width
                        self.currentShape.height = height
                    }
                    shapes[shapes.count-1] = self.currentShape
                }
              })
            .onEnded({ value in
                self.isDragging = false
                if self.shapeType == .rectangle {
                    if(self.currentShape.width < 5 || self.currentShape.height < 5) {
                        _ = shapes.popLast()
                    }
                }
                self.currentShape = ShapeDetails()
            })
        )
        .frame(width: 800, height: 500, alignment: .center)
        .clipped()
    }
    
    var body: some View {
        VStack {
            editorView
            
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
                    if shapes.count == 0 {
                        return
                    }
                    
                    _ = shapes.popLast()
                }.keyboardShortcut("Z")
                
                Button("Shapes \(shapes.count)"){}
                
            }.padding([.top, .bottom], 10)
            
            // Canvas controller
            HStack {
                Slider(value: $thickness, in: 1...20) {
                    Text("Thickness")
                }.frame(maxWidth: 200)
                    .onChange(of: thickness) { newThickness in
                        self.thickness = newThickness
                    }
                Toggle("Fill", isOn: self.$shapeFill)
                Divider()
                .pickerStyle(RadioGroupPickerStyle())
                .frame(width: 100, height: 100)
                Divider()
                Button("Rectangle") {
                    shapeType = ShapeType.rectangle
                }
                
                Button("Arrow") {
                    shapeType = ShapeType.arrow
                }
                Divider()
                ColorPickerView(selectedColor: self.$selectedColor)
                    .onChange(of: self.selectedColor) { newColor in
                        print(newColor)
                        self.selectedColor = newColor
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
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
