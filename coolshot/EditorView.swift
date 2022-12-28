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
    var editorViewModel = EditorViewModel()
    
    @EnvironmentObject var imageModel: ImageModel
  
    
//    @State private var image = NSImage(named: "out")
    @State private var selectedColors = [Color.red, Color.green, Color.blue]
    
    @State private var thickness: Double = 3.0
    @State private var padding: Double = 20.0
    @State private var cornerRadius: Double = 20.0


    @State private var selectedColor: Color = .white
    @State private var shapeFill = false
    @State private var isDragging: Bool = false
    @State private var shapeType: ShapeType = .arrow

    
    @State private var shapes: [ShapeDetails] = []
    @State private var currentShape: ShapeDetails = ShapeDetails()
    
    var editorView: some View {
        ZStack(alignment: .topLeading) {
            
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: self.selectedColors),
                   startPoint: .topLeading,
                   endPoint: .bottomTrailing)
                
                Image(nsImage: (imageModel.image))
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(self.cornerRadius)
                    .padding(self.padding)
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
        HStack {
            VStack {
                editorView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                HStack {
                    Button(action: {
                        imageModel.image = editorViewModel.takeScreenShot()
                    }) {
                        Text("Take")
                            .padding([.top,.bottom], 20)
                    }
                    
                    Button("Copy ⌘C") {
                        editorViewModel.copyToClipboard(view: editorView)
                        if let _ = Storage.shared.value(.autoclose_on_copy, defaultValue: false) as? Bool {
                            NSApplication.shared.keyWindow?.close()
                        }
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
                }
                .padding([.top, .bottom], 10)
                .frame(height: 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
            
                VStack {
                    VStack {
                        VStack(alignment: .leading) {
                            Spacer()
                            Text("Shape")
                            
                            HStack {
                                Image(systemName: "arrow.up.right")
                                    .frame(width: 50, height: 25)
                                    .foregroundColor(Color.white)
                                    .background(shapeType == ShapeType.arrow ? Color.black : Color.gray)
                                    .padding(3)
                                    .border(.gray, width: 2)
                                    .gesture(TapGesture().onEnded{
                                        shapeType = ShapeType.arrow
                                    })
                                
                                Image(systemName: "rectangle")
                                    .frame(width: 50, height: 25)
                                    .foregroundColor(Color.white)
                                    .background(shapeType == ShapeType.rectangle ? Color.black : Color.gray)
                                    .padding(3)
                                    .border(.gray, width: 2)
                                    .gesture(TapGesture().onEnded{
                                        shapeType = ShapeType.rectangle
                                    })
                            }.padding(.bottom, 20)
                            
                            Group {
                                Text("Thickness")
                                Slider(value: $thickness, in: 1...20).frame(maxWidth: 200)
                                    .onChange(of: thickness) { newThickness in
                                        self.thickness = newThickness
                                    }
                            }
                            
                            Toggle("Fill", isOn: self.$shapeFill)
                                .pickerStyle(RadioGroupPickerStyle())
                            
                            ColorPickerView(selectedColor: self.$selectedColor)
                                .padding(.vertical, 10)
                                .onChange(of: self.selectedColor) { newColor in
                                    print(newColor)
                                    self.selectedColor = newColor
                                }
                            
                            
                            Group {
                                Text("Background")
                                    .bold()
                                    .padding(.top, 30)
                                Divider()
                            }
                            
                            Group {
                                Text("Padding")
                                Slider(value: $padding, in: 1...100).frame(maxWidth: 200)
                                    .onChange(of: padding) { val in
                                        self.padding = val
                                    }
                            }
                            
                            Group {
                                Text("Corner Radius")
                                Slider(value: $cornerRadius, in: 1...100).frame(maxWidth: 200)
                                    .onChange(of: cornerRadius) { val in
                                        self.cornerRadius = val
                                    }
                            }
                        }
                        
                        // Backgrounds
                        HStack {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 10) {
                                ForEach(editorViewModel.gradientObjects, id: \.self) { go in
                                    LinearGradient(
                                        gradient: Gradient(colors: go),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
                                    .frame(width: 40, height: 40)
                                    .border(.black, width: 0.5)
                                    .cornerRadius(5)
                                    .gesture(TapGesture().onEnded{
                                        selectedColors = go
                                    })
                                }
                            }
                            .padding([.trailing, .bottom], 10)
                        }
                        
                        Spacer()
                    }
                }
                .frame(width: 250)
                .clipped()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
