//
//  ContentView.swift
//  Habito
//
//  Created by Gurjit Singh on 02/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import SwiftUI
import CoreData
import UIKit
import Foundation
import UserNotifications

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
    @State var selectedDate: String = ""
    @State var uuid = "4D7BC347-E708-453E-9C58-EBDF48FDB263"
    
    init() {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: HabitDB.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitDB.time, ascending: false)]) var habitDb: FetchedResults<HabitDB>
    
    var body: some View {
        NavigationView {
            ZStack
                {
                    //set background image
                    Image("back")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .leading) {
                        //list of dates of month
                            Text("Date: \(getDisplayDate)").onAppear() {
                                self.selectedDate = self.getDisplayDate
                            }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                        List {
                            //horizontal scroll view for dates
                            ScrollView(.horizontal,showsIndicators: false, content: {
                                HStack(spacing: 10) {
                                    
                                    ForEach(startDateOfMonth..<endDateOfMonth, id: \.self) { index in
                                        
                                        Button(action: {
                                            self.selectedDate = "\(index + 1)-\(self.getCurrentMonthAndYear())"
                                            
                                        }) {
                                            if Int(self.getCurrentDate()) == (index + 1) {
                                                VStack {
                                                    //display days and day of week
                                                    Text("\(index + 1)").foregroundColor(Color.white).padding(8).font(.headline)
                                                    Text("\(self.getWeekDay(day: index))").foregroundColor(Color.white).padding(8).font(.headline)
                                                }.background(Color.purple)
                                            } else {
                                                VStack {
                                                    //display days and day of week
                                                    Text("\(index + 1)").foregroundColor(Color.white).padding(8).font(.headline)
                                                    Text("\(self.getWeekDay(day: index))").foregroundColor(Color.white).padding(8).font(.headline)
                                                }
                                            }
                                        }.background(Image("date_back").resizable())
                                            .cornerRadius(8)
                                        
                                    }
                                    
                                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                            })
                        }.frame(height: 100)
                        
                        //list to display habits
                        List {
                            
                            ForEach(habitDb, id: \.self) { item in
                                
                                HStack() {
                                    //display progress
                                    Text("\(getDataFromDB(id: item.id!, date: self.getDisplayDate)) %").rotationEffect(Angle(degrees: -90)).foregroundColor(Color.white).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                                    Text("\(item.name!)").font(.title).foregroundColor(Color.white)
                                    Spacer()
                                    //custom check box view
                                    
                                    CheckBoxCustomView(habitId: item.id!, selectDate: self.getDisplayDate, completedHabitId: self.stringToUUID(input: self.uuid))
                                    
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
                    .foregroundColor(Color(red: 244 / 255, green: 118 / 255, blue: 94 / 255))
            }
        }
        
    }
    
    //change string to UUID
           func stringToUUID(input: String) -> UUID {
               let getInput = UUID(uuidString: input)!
               return getInput
           }
    
    //get start date of month
    private var startDateOfMonth: Int {
        //get components of current date
        let getData = Calendar.current.dateComponents([.year, .month], from: currentDate)
        let startDate = Calendar.current.date(from: getData)!
        //format date to string
        let formattedDate = formatter(date: startDate)
        //change string to int and return it
        let changeToInt = Int(formattedDate) ?? 0
        return changeToInt
    }
    
    //get end date of month
    private var endDateOfMonth: Int {
        //get components of current date
        var getData = Calendar.current.dateComponents([.year, .month], from: currentDate)
        getData.month = (getData.month ?? 0) + 1
        getData.hour = (getData.hour ?? 0) - 1
        //get end date of month
        let endDate = Calendar.current.date(from: getData)!
        //format date to string
        let formattedDate = formatter(date: endDate)
        //change string to int and return it
        let changeToInt = Int(formattedDate) ?? 0
        return changeToInt
    }
    
    //function to format date and return string
    private func formatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        let resultString = dateFormatter.string(from: date)
        //get string prefix means get date and return
        return String(resultString.prefix(2))
    }
    
    //function to get week of day
    private func getWeekDay(day: Int) -> String {
        //create string variable to store week day
        var stringWeekDay = ""
        //get componets of current date
        let getComponents = Calendar.current.dateComponents([.year, .month], from: currentDate)
        let month = getComponents.month ?? 0
        let year = getComponents.year ?? 0
        //add one to index value
        let getDate = day + 1
        //concatenate components of date
        let conDateComponents = "\(getDate) " + "\(month) " + "\(year)"
        //get week day
        let weekday = Calendar.current.component(.weekday, from: stringToDate(string: conDateComponents))
        //switch case to assign weekday
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
        
        //return weekday
        return stringWeekDay
        
    }
    
    //function to convert string to date
    private func stringToDate(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "d M y"
        let date = formatter.date(from: string)!
        return date
    }
    
    //change date to string
    func changeDateToString(adate: Date) -> String {
        let adate =  adate
        //let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        let result = formatter.string(from: adate)
        return result
    }
    
    private func stringToDateCompleted(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "d-M-y"
        let date = formatter.date(from: string)!
        return date
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        let result = formatter.string(from: currentDate)
        return String(result.prefix(2))
    }
    
    private var getDisplayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d-M-y"
        return formatter.string(from: currentDate)
    }
    
    private func getCurrentMonthAndYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M-y"
        return formatter.string(from: currentDate)
    }
}

struct CheckBoxCustomView: View {
    
    @State var habitId: UUID
    @State var selectDate: String
    @State var completedHabitFound = false
    @State var showCheckbox = false
    @State var completedHabitId: UUID
    
    @Environment(\.managedObjectContext) var mocHabitCompleted
    @FetchRequest(entity: HabitCompleted.entity(), sortDescriptors: []) var habitCompleted: FetchedResults<HabitCompleted>
    
    var body: some View {
        HStack {
            ForEach(self.habitCompleted, id: \.self) { data in
                Text("").onAppear() {
                    if data.habitid! == self.habitId && (data.completedate! == self.stringToDateCompleted(string: self.selectDate)) {
                            //self.stringToDateCompleted(string: self.selectedDate)
                            self.completedHabitFound.toggle()
                        self.completedHabitId = data.id!
                    }
                    
                }.hidden()
            }
            if completedHabitFound {
                Button(action: {
                    deleteHabit(id: self.completedHabitId)
                    self.completedHabitFound.toggle()
                }) {
                    Image(systemName: "checkmark.square").foregroundColor(Color.white).font(.title)
                }
            } else {
                Button(action: {
                    completedHabit(habitID: self.habitId, completedDate: self.stringToDateCompleted(string: self.selectDate))
                }) {
                    Image(systemName: "square").foregroundColor(Color.white).font(.title)
                }
            }
        }
    }
    
    private func stringToDateCompleted(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "d-M-y"
        let date = formatter.date(from: string)!
        return date
    }
}

struct MetricsView: View {
    
    let currentDate = Date()
    
    @Environment(\.managedObjectContext) var moc
       @FetchRequest(entity: HabitDB.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitDB.time, ascending: false)]) var habitDb: FetchedResults<HabitDB>
    
    
    var body: some View {
        NavigationView {
            ZStack
                {
                    Image("back")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                            Spacer()
                            ZStack {
                                
                                MetricsProgressBar(height: 300, to: 0.8, color: .red)
                                MetricsProgressBar(height: 230, to: 0.45, color: .yellow)
                            
                                ForEach(habitDb, id: \.self) { item in
                                    MetricsProgressBar(height: 100, to: CGFloat(getDataFromDB(id: item.id!, date: self.getDisplayDate) / 10), color: .green)
                                }
                        }.padding()
                            Spacer()
                        List {
                            Section(header: Text("All Habits (This Month)")){
                                ForEach(habitDb, id: \.self) { item in
                                    HStack {
                                        Text("\(item.name!)").font(Font.headline.weight(.bold)).foregroundColor(getAccentColor())
                                        Spacer()
                                        Text("\(getDataFromDB(id: item.id!, date: self.getDisplayDate)) %")
                                    }
                                }
                            }
                        }.padding()
                    }
            }
        }
    }
    
    private var getDisplayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d-M-y"
        return formatter.string(from: currentDate)
    }
    
    private var getRandomNumber: CGFloat {
        let randomInt = Int.random(in: 10...300)
        return CGFloat(randomInt)
    }
}

//custom calender
struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }

    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}

//view to show progress in chart
struct MetricsProgressBar: View {
    
    var height: CGFloat
    var to: CGFloat
    var color: Color
    
    var body: some View {
        ZStack {
            //create circle
            Circle()
            .trim(from: 0, to: 1)
                .stroke(Color.black.opacity(0.25), style: StrokeStyle(lineWidth: 25, lineCap: .round))
                .frame(height: height)
            Circle()
            .trim(from: 0, to: to)
                .stroke(color, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                .frame(height: height)
        }.rotationEffect(.init(degrees: 270))
        
    }
}

struct CustomBar: View {
    
    @State var percentage: CGFloat = 0
    var dayOfWeek = ""
    
    var body: some View {
        VStack {
            Text(String(format: "%.0f", Double(percentage)) + " %").foregroundColor(Color.black).opacity(0.5)
            Rectangle().fill(getAccentColor()).frame(width: UIScreen.main.bounds.width / 7 - 12, height: getBarHight())
            Text("\(dayOfWeek)").foregroundColor(Color.black).opacity(0.5)
        }
    }
    
    private func getBarHight() -> CGFloat {
        return 200 / 100 * percentage
    }
}

struct CustomBarChart: View {
    @State var percentage: CGFloat = 0
    var color: Color = .white
    var body: some View {
        HStack {
            Text(String(format: "%.0f", Double(percentage)) + " %").foregroundColor(Color.black).opacity(0.5)
            Capsule().fill(color).frame(width: percentage, height: 15)
        }.padding()
    }
    
    private func getBarHeight() -> CGFloat {
        return 200 / 100 * percentage
    }
}

//view to add new habit
struct NewHabbitView: View {
    
    @Binding var showSheetNewHabbit: Bool
    @State var newHabbit: String
    @State var description: String
    @State var isDataSave = false
    @State var isEmptyFieldAlertShown = false
    @State var showReminderDetail: Bool
    @State var remAlarm: Date
    @State var remMode = [0]
    let notificationManager = SetNotification()
    let days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    @State var daysToString = ""
    
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
                            Section {
                                VStack(alignment: .leading) {
                                    Text("Name").font(Font.headline.weight(.semibold))
                                        .foregroundColor(getAccentColor())
                                    TextField("Name", text: $newHabbit)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .foregroundColor(Color.gray)
                                        .font(.headline)
                                }
                                
                                Section {
                                    VStack(alignment: .leading) {
                                        Text("Desciption").font(Font.headline.weight(.semibold))
                                            .foregroundColor(getAccentColor())
                                        TextField("Description", text: $description)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .foregroundColor(Color.gray)
                                            .font(.headline)
                                    }
                                }
                                
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
                                        DatePicker("Alarm", selection: $remAlarm, displayedComponents: .hourAndMinute)
                                    }
                                }
                                
                                
                                Section {
                                    HStack {
                                        Text("Repeat")
                                        
                                        NavigationLink(destination: RepeatModeSelectView(selectedDays: $remMode)) {
                                            Spacer()
                                            
                                            Text("\(removeLastChar(string: daysToString))").foregroundColor(Color.gray).onAppear() {
                                                self.daysToString = ""
                                                for i in self.remMode {
                                                    self.daysToString = self.daysToString + self.days[i] + ","
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }.listStyle(GroupedListStyle())
                            .navigationBarTitle(("New Habbit"))
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
                                        //*change repeat mode
                                        createNewHabit(name: self.newHabbit, desc: self.description, repeatMode: self.daysToString, aDate: self.remAlarm)
                                        self.isDataSave.toggle()
                                        if self.showReminderDetail {
                                            self.notificationManager.setPermissions()
                                            self.notificationManager.setNotification(aTitle: self.newHabbit, aDesc: self.description, aDate: self.remAlarm, aMode: self.remMode)
                                        }
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
                                
                        ).foregroundColor(getAccentColor())
                            .font(Font.headline.weight(.semibold))
                        Spacer()
                        Spacer()
                    }
            }
        }
    }
    
    func removeLastChar(string: String) -> String {
        let result = string.dropLast()
        return String(result)
    }
}

func getAccentColor() -> Color {
    return Color(red: 244 / 255, green: 118 / 255, blue: 94 / 255)
}

func getBackgroundColor() -> Color {
    return Color(red: 226 / 255, green: 223 / 255, blue: 223 / 255)
}

struct RepeatModeSelectView: View {
    
    let dayOfWeek = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @Binding var selectedDays : [Int]
    
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
                            Text("\(self.dayOfWeek[index])")
                            Spacer()
                            Button(action: {
                                
                            }) {
                                if self.selectedDays.contains(index) {
                                    Image(systemName: "checkmark.square").imageScale(.large).foregroundColor(Color.orange)
                                } else {
                                    Image(systemName: "square").imageScale(.large).foregroundColor(Color.black)
                                }
                                
                            } .onTapGesture {
                                //self.reminderMode = self.dayOfWeek[index]
                                if self.selectedDays.contains(index) {
                                    let index = self.selectedDays.firstIndex(of: index)
                                    self.selectedDays.remove(at: index ?? 0)
                                } else {
                                    self.selectedDays.append(index)
                                }
                                print("\(self.selectedDays)")
                            }
                        }
                    }
                }.accentColor(getAccentColor())
        }.navigationBarTitle("Repeat")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavigationRepeatModeItem())
        
    }
}

struct NavigationRepeatModeItem: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }){
            HStack {
                Image(systemName: "chevron.left").imageScale(.medium).font(Font.headline.weight(.semibold)).foregroundColor(Color.red)
                Text("").font(.headline).fontWeight(.semibold).foregroundColor(Color.red)
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

func createNewHabit(name: String, desc: String, repeatMode: String, aDate: Date) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let moc = appDelegate.persistentContainer.viewContext
    let habitEntity = NSEntityDescription.entity(forEntityName: "HabitDB", in: moc)!
    let habit = NSManagedObject(entity: habitEntity, insertInto: moc)
    
    let date = Date()
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
    habit.setValue(date, forKey: "time")
    habit.setValue(aDate, forKey: "reminder")
    habit.setValue(repeatMode, forKey: "repeatMode")
    habit.setValue(0, forKey: "order")
    do {
        try moc.save()
    } catch let error as NSError {
        print("Error while saving.. \(error.userInfo)")
    }
    
}

func completedHabit(habitID: UUID, completedDate: Date) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let moc = appDelegate.persistentContainer.viewContext
    let habitEntity = NSEntityDescription.entity(forEntityName: "HabitCompleted", in: moc)!
    let habit = NSManagedObject(entity: habitEntity, insertInto: moc)
    
    let getDate = getCurrentDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM y"
    //change string to date
    let changedDate = formatter.date(from: getDate)
    
    //insert data
    habit.setValue(UUID(), forKey: "id")
    habit.setValue(habitID, forKey: "habitid")
    habit.setValue(completedDate, forKey: "completedate")
    habit.setValue(changedDate, forKey: "date")
    do {
        try moc.save()
        print("Habit completed")
    } catch let error as NSError {
        print("Error while saving.. \(error.userInfo)")
    }
    
}

func deleteHabit(id: UUID) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let moc = appDelegate.persistentContainer.viewContext
    let habitEntity = NSFetchRequest<NSFetchRequestResult>(entityName: "HabitCompleted")
    habitEntity.predicate = NSPredicate(format: "id = %@", "\(id)")
    
    do {
        let delete = try moc.fetch(habitEntity)
        let itemTodelete = delete[0] as! NSManagedObject
        moc.delete(itemTodelete)
        do {
            try moc.save()
        } catch {
            print("Error")
        }
        
        print("Habit deleted")
    } catch let error as NSError {
        print("Error while saving.. \(error.userInfo)")
    }
    
}

func getDataFromDB(id: UUID, date: String) -> Int {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return 0
    }
    let moc = appDelegate.persistentContainer.viewContext
    
    let habitEntity = NSFetchRequest<NSFetchRequestResult>(entityName: "HabitCompleted")
    habitEntity.predicate = NSPredicate(format: "habitid = %@", "\(id)")
    
    //current month and year
    let currentDate = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "M-y"
    let resultDate = formatter.string(from: currentDate)
    
    var count = 0
    var done = false
    do {
        let result = try moc.fetch(habitEntity)
        for data in result as! [NSManagedObject] {
            let date = data.value(forKey: "date") as! Date
            
            let changeDate = date
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "M-y"
            let resultfetched = formatter1.string(from: changeDate)
            
            if resultfetched == resultDate {
                count += 1
                print("\(count)")
                done.toggle()
            }
        }
    } catch let error as NSError {
        print("Error while fetching.. \(error.userInfo)")
    }
    
        let percentage = count * 100 / 30
        print("per \(percentage) count \(count) month \(resultDate)")
        return percentage
}

private func stringToDate(string: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "d-M-y"
    let date = formatter.date(from: string)!
    return date
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct type: Identifiable {
    var id: Int
    var percentage: CGFloat
    var day: String
}

var percents = [
    type(id: 0, percentage: 35, day: "Mon"),
    type(id: 1, percentage: 12, day: "Tue"),
    type(id: 2, percentage: 55, day: "Wed"),
    type(id: 3, percentage: 33, day: "Thu"),
    type(id: 4, percentage: 90, day: "Fri"),
    type(id: 5, percentage: 67, day: "Sat"),
    type(id: 6, percentage: 50, day: "Mon")
]
