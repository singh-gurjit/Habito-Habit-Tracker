//
//  GridCalender.swift
//  Habito
//
//  Created by Gurjit Singh on 20/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

struct GridCalender: View {
    let rows = 5
    let columns = 7
    let days = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    var currentDate = 1
    @State var hiddenView = false
    var weeks = 0
    var items = [[Date]]()
    lazy var dateFormatter: DateFormatter = {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    var date = Date()
    var habitID: UUID = UUID()
    
    init(id: UUID) {
        self.habitID = id
        setCalendar()
        getCompletedHabitRecord()
    }
    var completeDate = [Date]()
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                ForEach(0..<7, id: \.self) { index in
                    Text("\(self.days[index])")
                }
            }
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(spacing: 15) {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        //self.content(row, column)
                        VStack {
                            Image(systemName: "\(self.configureCell(date: self.items[row][column])).circle").font(.largeTitle)
                        }
                    }
                }.padding(10)
            }
        }.frame(maxWidth: .infinity)
    }
    
    var cell:(Int, Int) -> String = { row, col in
        let result: String
        
        result = "\((row * 7) + col).circle"
        
        return result
    }
    
    mutating func setCalendar() {
            let cal = Calendar.current
            let components = (cal as NSCalendar).components([.month, .day,.weekday,.year], from: date)
            let year =  components.year
            let month = components.month
            //let months = dateFormatter.monthSymbols
            //let monthSymbol = (months![month!-1])
            //lblMonth.text = "\(monthSymbol) \(year!)"

            let weekRange = (cal as NSCalendar).range(of: .weekOfMonth, in: .month, for: date)
            //let dateRange = (cal as NSCalendar).range(of: .day, in: .month, for: date)
            weeks = weekRange.length
            //let totalDaysInMonth = dateRange.length

            let totalMonthList = weeks * 7
            var dates = [Date]()
            var firstDate = dateFormatter.date(from: "\(year!)-\(month!)-1")!
            let componentsFromFirstDate = (cal as NSCalendar).components([.month, .day,.weekday,.year], from: firstDate)
            firstDate = (cal as NSCalendar).date(byAdding: [.day], value: -(componentsFromFirstDate.weekday!-1), to: firstDate, options: [])!

            for _ in 1 ... totalMonthList {
                dates.append(firstDate)
                firstDate = (cal as NSCalendar).date(byAdding: [.day], value: +1, to: firstDate, options: [])!
            }
            let maxCol = 7
            let maxRow = weeks
            items.removeAll(keepingCapacity: false)
            var i = 0
           
            for _ in 0..<maxRow {
                var colItems = [Date]()
                for _ in 0..<maxCol {
                    colItems.append(dates[i])
                    i += 1
                }
                //print(colItems)
                items.append(colItems)
            }
           
        }
        
        func configureCell(date: Date) -> String {
            let cal = Calendar.current
            let components = (cal as NSCalendar).components([.day], from: date)
            let day = components.day!
            return String(day)
        }
    
    mutating func getCompletedHabitRecord() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let moc = delegate.persistentContainer.viewContext
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "HabitCompleted")
        fetchReq.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: false)]
        //fetchReq.predicate = NSPredicate(format: "habitid = %@", "\(habitID)")
        do {
            let result = try moc.fetch(fetchReq)
            print("count: \(result.count)")
            for data in result as! [NSManagedObject] {
               let date = data.value(forKey: "completedate") as! Date
                completeDate.append(date)
            }
            print("Record: \(completeDate)")
        } catch {
            print("Failed to retrieve")
        }
    }
}
