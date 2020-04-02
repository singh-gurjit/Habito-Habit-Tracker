//
//  ContentView.swift
//  Habito
//
//  Created by Gurjit Singh on 02/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Text("Home")
                Spacer()
                HStack {
                    //Dashboard
                    Image(systemName: "house")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(width: geometry.size.width/3, height: 75)
                    //Add
                    ZStack {
                        Circle()
                            .foregroundColor(Color.white)
                            .frame(width: 75, height: 75)
                        Image(systemName: "plus.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 75)
                            .foregroundColor(Color.orange)
                    } .offset(y: -geometry.size.height/10/2)
                    //Metrics
                    Image(systemName: "chart.bar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
                    .frame(width: geometry.size.width/3, height: 75)
                }.frame(width: geometry.size.width, height: geometry.size.height/10)
                    .background(Color.white.shadow(radius: 2))
            }.edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
