//
//  HabitDetailView.swift
//  Habito
//
//  Created by Gurjit Singh on 20/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import SwiftUI

struct HabitDetailView: View {
    
    let days = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    @Binding var isPresented: Bool
    @State var habID: UUID
    
    var body: some View {
        NavigationView {
            ZStack
                {
                    Image("back")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    List {
                        Section(header: Text("Monthly Report").font(.headline).foregroundColor(.gray)) {
                            VStack {
                                GridCalender(id: habID)
                            }.padding()
                        }
                        
                        Section(header: Text("Weekly Report").font(.headline).foregroundColor(.gray)) {
                            VStack {
                                HStack(spacing: 10) {
                                    Spacer()
                                    ForEach(0..<7, id: \.self) { index in
                                        VStack(spacing: 10) {
                                            Image(systemName: "circle.fill").font(.title)
                                            Spacer()
                                            Text("\(self.days[index])").font(.headline)
                                        }
                                    }
                                    Spacer()
                                }
                            }.padding()
                        }
                    }.listStyle(GroupedListStyle())
            }
                //.navigationBarTitle("Detail")
                .navigationBarItems(trailing:
                    Button(action: {
                        self.isPresented = false
                    }) {
                        Text("Done")
                    }
                    
            ).foregroundColor(getAccentColor())
                .font(Font.headline.weight(.semibold))
        }
    }
}
