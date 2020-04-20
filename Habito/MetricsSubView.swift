//
//  MetricsSubView.swift
//  Habito
//
//  Created by Gurjit Singh on 20/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import SwiftUI

struct MetricsSubView: View {
    @State var showHabitDetailView = false
    
    var body: some View {
        List{
            GridStack(rows: 5, columns: 2) { row, col in
                    VStack(alignment: .center) {
                        HStack {
                            Text("Habit").foregroundColor(Color.white).font(.title)
                        Spacer()
                            Text(">").foregroundColor(Color.white).font(.title)
                        }.padding(10)
                        HStack {
                            MetricsProgressBar(height: 70, to: 0.3, color: .white)
                            Spacer()
                            Text("20% Completed").foregroundColor(Color.white).font(.subheadline)
                        }.padding(10)
                        Spacer()
                        
                    }.frame(width: 180, height: 180, alignment: .topLeading)
                        .background(getAccentColor())
                        .cornerRadius(20)
                    .padding(5)
                    .onTapGesture {
                        self.showHabitDetailView.toggle()
                    }.sheet(isPresented: self.$showHabitDetailView) {
                    HabitDetailView(isPresented: self.$showHabitDetailView)
                }
            }
        }
    }
    
}
