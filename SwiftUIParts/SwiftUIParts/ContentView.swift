//
//  ContentView.swift
//  SwiftUIParts
//
//  Created by 田籠聡 on 2023/03/31.
//

import SwiftUI

struct ContentView: View {
    @State var geometry = ResizeableBoxGeometry(size: CGSize(width: 200, height: 200))

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("Size, width:\(geometry.size.width), height:\(geometry.size.height)")
                Text("Origin X:\(geometry.origin.x), Y:\(geometry.origin.y)")
                    .padding(.init(top: 0, leading: 0, bottom: 50, trailing: 0))
            }
            ResizeableBox(name: "selecting", geometry: $geometry)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
