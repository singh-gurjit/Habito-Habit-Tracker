//
//  ContentView.swift
//  Habito
//
//  Created by Gurjit Singh on 02/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import SwiftUI
import CoreData

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
                    Image("home_dark")
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
                        Image("plusbtn")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color.orange)
                            .onTapGesture {
                                self.isAddNewHabbitShown.toggle()
                        }
                        .sheet(isPresented: self.$isAddNewHabbitShown) {
                            NewHabbitView(showSheetNewHabbit: self.$isAddNewHabbitShown, newHabbit: "", description: "",showReminderDetail: false, remAlarm: Date())
                        }
                    } .offset(y: -geometry.size.height/10/2)
                    //Metrics
                    Image("metrics_dark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(width: geometry.size.width/3, height: 65)
                        .onTapGesture {
                            self.viewNavigation.currentVisibleView = "metrics"
                    }
                }.frame(width: geometry.size.width, height: geometry.size.height/10)
                    .background(Color.white.shadow(color: .orange,radius: 2))
            }.edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct DashboardView: View {
    
    var currentDate = Date()
    
    init() {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: HabitDB.entity(), sortDescriptors: []) var habitDb: FetchedResults<HabitDB>
    
    var body: some View {
        NavigationView {
            ZStack
                {
                    Image("back")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        
                        List {
                            ScrollView(.horizontal,showsIndicators: false, content: {
                                HStack(spacing: 10) {
                                    
                                    ForEach(startDateOfMonth..<endDateOfMonth, id: \.self) { index in
                                        VStack {
                                            Text("\(index + 1)").foregroundColor(Color.white).padding(8).font(.headline)
                                            Text("\(self.getWeekDay(day: index))").foregroundColor(Color.white).padding(8).font(.headline)
                                        }.background(Image("date_back").resizable())
                                            .cornerRadius(8)
                                    }
                                    
                                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                            })
                        }.frame(height: 100)
                        
                        List {
                            
                            ForEach(habitDb, id: \.self) { item in
                                
                                HStack() {
                                    Text("10 %").rotationEffect(Angle(degrees: -90)).foregroundColor(Color.white)
                                    Text("\(item.name!)").font(.title).foregroundColor(Color.white)
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                    }) {
                                        Image(systemName: "square").font(.title).foregroundColor(Color.white)
                                    }.onTapGesture {
                                        print("Clicked")
                                    }
                                    
                                }.padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 10))
                                    .background(Image("back_orange").resizable())
                            }
                            .onDelete { (indexSet) in
                                for offset in indexSet {
                                    let habit = self.habitDb[offset]
                                    self.moc.delete(habit)
                                }
                                try? self.moc.save()
                            }
                            
                        }
                        
                    }
                    .navigationBarItems(trailing: EditButton()).font(Font.headline.weight(.semibold))
            }
        }
    }
    
    private var startDateOfMonth: Int {
        let getData = Calendar.current.dateComponents([.year, .month], from: currentDate)
        let startDate = Calendar.current.date(from: getData)!
        let formattedDate = formatter(date: startDate)
        let changeToInt = Int(formattedDate) ?? 0
        return changeToInt
    }
    
    private var endDateOfMonth: Int {
        var getData = Calendar.current.dateComponents([.year, .month], from: currentDate)
        getData.month = (getData.month ?? 0) + 1
        getData.hour = (getData.hour ?? 0) - 1
        let endDate = Calendar.current.date(from: getData)!
        let formattedDate = formatter(date: endDate)
        let changeToInt = Int(formattedDate) ?? 0
        return changeToInt
    }
    
    private func formatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        let resultString = dateFormatter.string(from: date)
        return String(resultString.prefix(2))
    }
    
    private func getWeekDay(day: Int) -> String {
        var stringWeekDay = ""
        let getComponents = Calendar.current.dateComponents([.year, .month], from: currentDate)
        let month = getComponents.month ?? 0
        let year = getComponents.year ?? 0
        let getDate = day + 1
        let conDateComponents = "\(getDate) " + "\(month) " + "\(year)"
        let weekday = Calendar.current.component(.weekday, from: stringToDate(string: conDateComponents))
        switch weekday {
        case 1:
            stringWeekDay = "S"
        case 2:
            stringWeekDay = "M"
        case 3:
            stringWeekDay = "T"
        case 4:
            stringWeekDay = "W"
        case 5:
            stringWeekDay = "T"
        case 6:
            stringWeekDay = "F"
        case 7:
            stringWeekDay = "S"
        default:
            print("Unknown")
        }
        
        //print("\(conDateComponents)")
        return stringWeekDay
        
    }
    
    private func stringToDate(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "d M y"
        let date = formatter.date(from: string)!
        return date
    }
    
}

struct MetricsView: View {
    
    init() {
        UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ZStack
                {
                    Image("back")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("Metrics").font(.title)
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
                        }
                        
                    }
            }
        }
    }
}

struct NewHabbitView: View {
    
    @Binding var showSheetNewHabbit: Bool
    @State var newHabbit: String
    @State var description: String
    @State var isDataSave = false
    @State var isEmptyFieldAlertShown = false
    @State var showReminderDetail: Bool
    @State var remAlarm: Date
    @State var remMode = "None"
    
    var body: some View {
        NavigationView {
            ZStack
                {
                    Image("back")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    List {
                        Section {
                            TextField("Name", text: $newHabbit)
                            TextField("Description", text: $description)
                        }
                        Section {
                            VStack {
                                HStack {
                                    Toggle(isOn: $showReminderDetail) {
                                        Text("Reminder")
                                        
                                    }
                                    
                                }
                                if showReminderDetail {
                                    Divider()
                                    //Text("\(reminderDate, formatter: dateFormatter)")
                                    DatePicker("Alarm", selection: $remAlarm)
                                    
                                }
                            }
                        }
                        
                        Section {
                            HStack {
                                Text("Repeat")
                                
                                NavigationLink(destination: RepeatModeSelectView(reminderMode: $remMode)) {
                                    Spacer()
                                    Text(self.remMode).foregroundColor(Color.gray)
                                }
                            }
                        }
                    }.listStyle(GroupedListStyle())
                        .navigationBarTitle(("New Habbit"), displayMode: .inline)
                        .navigationBarItems(leading:
                            Button("Cancel") {
                                self.showSheetNewHabbit.toggle()
                            }
                            ,trailing:
                            Button(action: {
                                if (self.newHabbit.isEmpty) {
                                    self.isEmptyFieldAlertShown.toggle()
                                    print("Empty Data")
                                } else {
                                    createNewHabit(name: self.newHabbit, desc: self.description, repeatMode: self.remMode)
                                    self.isDataSave.toggle()
                                    
                                }
                                if self.isDataSave == true {
                                    self.showSheetNewHabbit.toggle()
                                }
                            }) {
                                Text("Done")
                            }
                            .alert(isPresented: $isEmptyFieldAlertShown) {
                                Alert(title: Text("Alert"), message: Text("Please fill all fields to proceed."), dismissButton: .default(Text("OK")))
                            }
                            
                    )
            }
        }
    }
}

struct RepeatModeSelectView: View {
    @Binding var reminderMode: String
    let dayOfWeek = ["None","Everyday","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    var body: some View {
        ZStack
            {
                Image("back")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                List {
                    ForEach(0..<dayOfWeek.count) { index in
                        HStack {
                            Text(self.dayOfWeek[index])
                            Spacer()
                            Button(action: {
                                
                            }) {
                                if self.reminderMode == self.dayOfWeek[index] {
                                    Image(systemName: "checkmark.square").imageScale(.large).foregroundColor(Color.orange)
                                } else {
                                    Image(systemName: "square").imageScale(.large).foregroundColor(Color.black)
                                }
                                
                            } .onTapGesture {
                                self.reminderMode = self.dayOfWeek[index]
                            }
                        }
                    }
                }
        }
    }
}

func getCurrentDate() -> String {
    let todayDate = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = ("d MMM y")
    let resultDate = formatter.string(from: todayDate)
    return resultDate
}

func createNewHabit(name: String, desc: String, repeatMode: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let moc = appDelegate.persistentContainer.viewContext
    let habitEntity = NSEntityDescription.entity(forEntityName: "HabitDB", in: moc)!
    let habit = NSManagedObject(entity: habitEntity, insertInto: moc)
    
    let getDate = getCurrentDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM y"
    //change string to date
    let changedDate = formatter.date(from: getDate)
    
    //insert data
    habit.setValue(UUID(), forKey: "id")
    habit.setValue(name, forKey: "name")
    habit.setValue(desc, forKey: "descrip")
    habit.setValue(changedDate, forKey: "date")
    habit.setValue("", forKey: "time")
    habit.setValue(changedDate, forKey: "reminder")
    habit.setValue(repeatMode, forKey: "repeatMode")
    habit.setValue(0, forKey: "order")
    do {
        try moc.save()
    } catch let error as NSError {
        print("Error while saving.. \(error.userInfo)")
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
