//
//  ContentView.swift
//  Habito
//
//  Created by Gurjit Singh on 02/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewNavigation = ViewNav()
    @State var isAddNewHabbitShown = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                if self.viewNavigation.currentVisibleView == "home" {
                    DashboardView()
                } else if self.viewNavigation.currentVisibleView == "metrics" {
                    MetricsView()
                }
                Spacer()
                HStack {
                    //Dashboard
                    Image(systemName: "house")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(width: geometry.size.width/3, height: 65)
                        .onTapGesture {
                            self.viewNavigation.currentVisibleView = "home"
                    }
                    //Add
                    ZStack {
                        Circle()
                            .foregroundColor(Color.white)
                            .frame(width: 70, height: 70)
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color.orange)
                            .onTapGesture {
                                self.isAddNewHabbitShown.toggle()
                        }
                        .sheet(isPresented: self.$isAddNewHabbitShown) {
                            NewHabbitView(showSheetNewHabbit: self.$isAddNewHabbitShown, newHabbit: "", description: "")
                        }
                    } .offset(y: -geometry.size.height/10/2)
                    //Metrics
                    Image(systemName: "chart.bar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(width: geometry.size.width/3, height: 65)
                        .onTapGesture {
                            self.viewNavigation.currentVisibleView = "metrics"
                    }
                }.frame(width: geometry.size.width, height: geometry.size.height/10)
                    .background(Color.white.shadow(radius: 2))
            }.edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct DashboardView: View {
    
    init() {
        UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 10) {
                    ForEach(0...5, id: \.self) { index in
                        VStack {
                            Text("\(index + 1)")
                            Text("M")
                        }
                    }
                }.frame(width: 400, alignment: .trailing)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                
                Spacer()
                List {
                    ForEach(0...5, id: \.self) { index in
                        HStack {
                            Text("List item: \(index)")
                            Spacer()
                            ForEach(0...5, id: \.self) { squareid in
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "square")
                                }.onTapGesture {
                                    print("Clicked")
                                }
                            }
                        }
                    }
                }
            }.navigationBarTitle("Dashboard")
        }
    }
}

struct MetricsView: View {
    
    init() {
        UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0...10, id: \.self) { index in
                    HStack(alignment: .center) {
                        ForEach(0...1, id: \.self) { item in
                            HStack {
                                Spacer()
                                Image(systemName: "house").frame(width:100, height: 100)
                                Spacer()
                            }
                        }
                    }
                }
            }        .navigationBarTitle("Metrics")
        }
    }
}

struct NewHabbitView: View {
    
    @Binding var showSheetNewHabbit: Bool
    @State var newHabbit: String
    @State var description: String
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Name", text: $newHabbit)
                    TextField("Description", text: $description)
                }
                Section {
                    HStack {
                        Text("Reminder")
                        Spacer()
                        Text("9:00 AM")
                    }
                }
                
                Section {
                    HStack {
                        Text("Repeat")
                        Spacer()
                        Text("Always")
                    }
                }
            }.listStyle(GroupedListStyle())
                .navigationBarTitle(("New Habbit"), displayMode: .inline)
                .navigationBarItems(leading:
                    Button("Cancel") {
                        self.showSheetNewHabbit.toggle()
                    }
                    ,trailing:
                    Button("Done") {
                        self.showSheetNewHabbit.toggle()
                    }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
