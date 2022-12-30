//
//  ColorPickerView.swift
//  coolshot
//
//  Created by Ahmed on 14.12.22.
//

import SwiftUI

struct Constants {
    
    struct Icons {
        static let plusCircle = "plus.circle"
        static let line3HorizontalCircleFill = "line.3.horizontal.circle.fill"
        static let circle = "circle"
        static let circleInsetFilled = "circle.inset.filled"
        static let exclaimationMarkCircle = "exclamationmark.circle"
        static let recordCircleFill = "record.circle.fill"
        static let trayCircleFill = "tray.circle.fill"
        static let circleFill = "circle.fill"
    }
    
}

struct ColorPickerView: View {
    
    let colors = [
        Color.white,
        Color.black,
        Color.red,
        Color.orange,
        Color.green,
        Color.blue,
        Color.purple,
    ]
    
    @Binding var selectedColor: Color
    
    var body: some View {
        HStack {
            ForEach(colors, id: \.self) { color in
            
                Image(systemName: selectedColor == color ? Constants.Icons.recordCircleFill : Constants.Icons.circleFill)
                    .foregroundColor(color)
                    .font(.system(size: 16))
                    .clipShape(Circle())
                    .onTapGesture {
                        selectedColor = color
                    }
            }
        }
    }
}

struct ColorListView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(selectedColor: .constant(.blue))
    }
}
