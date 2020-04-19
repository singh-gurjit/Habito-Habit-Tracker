//
//  TableView.swift
//  Habito
//
//  Created by Gurjit Singh on 19/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import SwiftUI

struct TableViewHabits: View {
    
    let colors: [Color] = [.red, .green, .blue, .orange, .pink, .purple, .yellow]
    let daysOfWeek = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    
    var body: some View {
        VStack {
        
            List {
                Section(header: Text("Habit Report").font(.headline)) {
                    
                    ScrollView(.horizontal,showsIndicators: false) {
                        HStack {
                        ForEach(0..<10) { index in
                            VStack {
                                HStack {
                                    Text("Habit").foregroundColor(Color.white).font(.title)
                                Spacer()
                                    Text(">").foregroundColor(Color.white).font(.title)
                                }.padding(20)
                                HStack {
                                    MetricsProgressBar(height: 70, to: 0.3, color: .white)
                                    Spacer()
                                    Text("20% Completed").foregroundColor(Color.white).font(.subheadline)
                                }.padding(10)
                            }.frame(width: 200, height: 200, alignment: .topLeading)
                                .background(getAccentColor())
                                .cornerRadius(20)
                        }
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    }
                }
                Section(header: Text("Daily Performance").font(.headline)) {
                    ForEach(0..<7) { index in
                        HStack {
                            Text("\(self.daysOfWeek[index])").frame(width:40).font(.subheadline)
                            CustomBarChart(percentage: CGFloat.random(in: 100...200), color: getAccentColor())
                        }
                    }
                }
                Section(header: Text("Completion Rate").font(.headline)) {
                    HStack(alignment: .bottom) {
                        ForEach(0..<7) { index in
                            CustomBar(percentage: CGFloat.random(in: 1...100), dayOfWeek: self.daysOfWeek[index], color: getAccentColor())
                        }
                    }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
            }.listStyle(GroupedListStyle())
        Spacer()
        }
    
    }
}
