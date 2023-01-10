
//  ContentView.swift
//  coolshot
//
//  Created by Ahmed on 05.12.22.
//

import SwiftUI
import AppKit
import UserNotifications
import Cocoa

struct EditorView: View {
    var editorViewModel = EditorViewModel()
    
    @State var imageModel: ImageModel
  
    @State private var selectedColorsIndex: Int
    
    @State private var thickness: Double
    @State private var padding: Double
    @State private var cornerRadius: Double

    @State private var selectedShapeColor: Color = .white
    @State private var background: Bool
    @State private var shapeFill: Bool
    @State private var shapeType: ShapeType = .none

    @State private var isDragging: Bool = false
    
    @State private var shapes: [ShapeDetails] = []
    @State private var currentShape: ShapeDetails = ShapeDetails()
    
    @State public var editorScale: CGFloat
    
    init(image: ImageModel) {
        self.imageModel = image
        self.editorScale = max(image.width, image.height) > 700 ? 0.7 : 1
        let storedBackgroundIndex = Storage.shared.value(.backgroundColors, defaultValue: 0) as! Int
        
        // reset background colors index on missing
        self.selectedColorsIndex = storedBackgroundIndex < editorViewModel.gradientObjects.count ? storedBackgroundIndex : 0
        
        
        self.thickness = Storage.shared.value(.shapeThickness, defaultValue: 3.0) as! Double
        self.padding = Storage.shared.value(.padding, defaultValue: 50.0) as! Double
        self.cornerRadius = Storage.shared.value(.radius, defaultValue: 20.0) as! Double
        
        self.background = Storage.shared.value(.background, defaultValue: true) as! Bool
        self.shapeFill = Storage.shared.value(.shapeFill, defaultValue: true) as! Bool
        
        
    }
    
    var editorView: some View {
        ZStack(alignment: .topLeading) {
            ZStack {
                if background {
                    LinearGradient(
                        gradient: Gradient(colors: editorViewModel.gradientObjects[self.selectedColorsIndex]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                    .frame(width: imageModel.width + self.padding, height: imageModel.height + self.padding)
                }
                
                Image(nsImage: (imageModel.image))
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(self.cornerRadius)
                    .frame(width: imageModel.width, height: imageModel.height)
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
                        color: self.selectedShapeColor,
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
                    if(shapes.count > 0) {
                        shapes[shapes.count-1] = self.currentShape
                    }
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
    }
    
    var body: some View {
        HStack {
            VStack {
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    editorView
                        .scaleEffect(editorScale)
                }
                .background(Color.black)
                .clipped()
                .gesture(MagnificationGesture()
                       .onChanged { value in
                           self.editorScale = value.magnitude
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                VStack(alignment: .leading) {
                    RightMenuContainer{
                        Text("Shape")
                            .foregroundColor(.white)
                        
                        HStack {
                            ForEach(EnabledShapes, id: \.self) { shape in
                                Image(systemName: shape.systemImageName)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color.white)
                                    .background(shape.type == shapeType ? Color("Buttons") : Color.gray)
                                    .cornerRadius(8)
                                    .opacity(shape.type == shapeType ? 1 : 0.5)
                                    .gesture(TapGesture().onEnded{
                                        shapeType = shape.type
                                    })
                            }
                        }
                        
                        Divider().padding([.top, .bottom], 5)
                        
                        HStack {
                            Text("Thickness")
                                .foregroundColor(.white)
                            Spacer()
                            Toggle("Fill", isOn: self.$shapeFill)
                                .foregroundColor(.white)
                                .pickerStyle(RadioGroupPickerStyle())
                                .onChange(of: self.shapeFill) { val in
                                    Storage.shared.set(.shapeFill, val)
                                }
                        }
                        Slider(value: $thickness, in: 1...20).frame(maxWidth: 200)
                            .onChange(of: thickness) { newThickness in
                                self.thickness = newThickness
                                Storage.shared.set(.shapeThickness, newThickness)
                            }
                        
                        ColorPickerView(selectedColor: self.$selectedShapeColor)
                            .padding(.vertical, 10)
                            .onChange(of: self.selectedShapeColor) { newColor in
                                self.selectedShapeColor = newColor
                            }
                    }
                    
                    RightMenuContainer{
                        HStack(alignment: .firstTextBaseline) {
                            Text("Padding")
                                .foregroundColor(.white)
                                .frame(width: 60)
                            
                            Slider(value: $padding, in: 1...500).frame(maxWidth: 200)
                                .onChange(of: padding) { val in
                                    self.padding = val
                                    Storage.shared.set(.padding, val)
                                }
                        }
                        
                        HStack(alignment: .firstTextBaseline) {
                            Text("Radius")
                                .foregroundColor(.white)
                                .frame(width: 60)
                            
                            Slider(value: $cornerRadius, in: 1...100).frame(maxWidth: 200)
                                .onChange(of: cornerRadius) { val in
                                    self.cornerRadius = val
                                    Storage.shared.set(.radius, val)
                                }
                        }
                    }
                }
                
                RightMenuContainer {
                    Toggle("Background", isOn: self.$background)
                        .foregroundColor(.white)
                        .pickerStyle(RadioGroupPickerStyle())
                        .bold()
                        .onChange(of: self.background) { val in
                            Storage.shared.set(.background, val)
                        }
                    
                    HStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 10) {
                            ForEach(Array(editorViewModel.gradientObjects.enumerated()), id: \.offset) { (index, go) in
                                LinearGradient(
                                    gradient: Gradient(colors: go),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
                                .frame(width: 40, height: 40)
                                .border(.white, width: self.selectedColorsIndex == index ? 3 : 0)
                                .cornerRadius(5)
                                .gesture(TapGesture().onEnded{
                                    self.selectedColorsIndex = index
                                    Storage.shared.set(.backgroundColors, index)
                                })
                            }
                        }
                        .padding([.trailing, .bottom], 10)
                    }
                }

                HStack(alignment: .bottom) {
                    Button("Copy ⌘C") {
                        var size = imageModel.image.size
                        size.width += self.padding
                        size.height += self.padding
                        editorViewModel.copyToClipboard(view: editorView, bounds: size)
                        if let close = Storage.shared.value(.autoclose_on_copy, defaultValue: true) as? Bool {
                            if close {
                                NSApplication.shared.keyWindow?.close()
                            }
                        }
                    }
                    .keyboardShortcut("C")
                    .foregroundColor(.white)
                    .background(Color("Buttons"))
                    
                    Button("Save ⌘S") {
                        var size = imageModel.image.size
                        size.width += self.padding
                        size.height += self.padding
                        editorViewModel.saveToFile(view: editorView, bounds: size)
                    }.keyboardShortcut("S")
                    
                    Button("Undo ⌘Z") {
                        if shapes.count == 0 {
                            return
                        }
                        
                        _ = shapes.popLast()
                    }.keyboardShortcut("Z")
                }.padding([.top,.bottom], 10)
                
                Spacer() // to stick items to the top always
            }
            .frame(width: 250)
            .clipped()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(image: ImageModel(image: NSImage(named: "AppIcon")!))
    }
}
