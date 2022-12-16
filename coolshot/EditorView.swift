//
//  ContentView.swift
//  coolshot
//
//  Created by Ahmed on 05.12.22.
//

import SwiftUI
import AppKit
import UserNotifications

struct ShapeDetails: Hashable {
    var type = "rec"
    var width = 0.0
    var height = 0.0
    var x = 0.0
    var y = 0.0
    var color = Color.black
    var thinkness = 1.0

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(x)
        hasher.combine(y)
    }
}


struct EditorView: View {
    @State private var image = NSImage(named: "out")
    @State private var selectedGradientIndex = 0
    
    @State private var thickness: Double = 1.0
    @State private var selectedColor: Color = .black
    @State private var isDragging: Bool = false
    
    var editorViewModel = EditorViewModel()
    
    @State private var shapes: [ShapeDetails] = []
    @State private var currentShape: ShapeDetails = ShapeDetails()
    
    var editorView: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                gradient: Gradient(colors: editorViewModel.gradientObjects[selectedGradientIndex]),
               startPoint: .topLeading,
               endPoint: .bottomTrailing)

            Image(nsImage: image!)
                .resizable()
                .scaledToFit()
                .cornerRadius(20)
                .padding(50)
            
            ForEach(shapes, id: \.self) { shape in
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: shape.width, height: shape.height)
                    .border(shape.color, width: shape.thinkness)
                    .offset(x: shape.x, y: shape.y)
                    .scaledToFit()
            }
    
        }.gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ value in
                if(value.translation.width < 0 || value.translation.height < 0) {
                    return
                }
                
                if isDragging == false {
                    isDragging = true
                    self.currentShape = ShapeDetails(
                        type: "rec",
                        width: 1,
                        height: 1,
                        x: value.location.x,
                        y: value.location.y,
                        color: self.selectedColor,
                        thinkness: self.thickness
                    )
                    shapes.append(currentShape)
                } else {
                    // scale the last object
                    self.currentShape.width = value.translation.width
                    self.currentShape.height = value.translation.height
                    shapes[shapes.count-1] = self.currentShape
                }
              })
            .onEnded({ value in
                self.isDragging = false
                self.currentShape = ShapeDetails()
            })
        ).border(.red, width: 3)
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
                if shapes.count == 0 {
                    return
                }
                
                _ = shapes.popLast()
            }.keyboardShortcut("Z")
            
            Button("Shapes \(shapes.count)"){}
            
        }.padding([.top, .bottom], 10)

        editorView
        
        // Canvas controller
        HStack {
            Slider(value: $thickness, in: 1...20) {
                Text("Thickness")
            }.frame(maxWidth: 200)
                .onChange(of: thickness) { newThickness in
                    self.thickness = newThickness
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
        }.padding(10)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
