//
//  RightMenuContainer.swift
//  RapidSnap
//
//  Created by Ahmed on 01.01.23.
//

import Foundation
import SwiftUI

struct RightMenuContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray)
                    .opacity(0.2)
                VStack(alignment: .leading) {
                    content
                }.padding(10)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .cornerRadius(10)
        .padding([.trailing], 7)
        .fixedSize(horizontal: false, vertical: true)
    }
}
