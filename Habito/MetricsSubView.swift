//
//  MetricsSubView.swift
//  Habito
//
//  Created by Gurjit Singh on 20/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

struct MetricsSubView: View {
    @State var showHabitDetailView = false
    var name = [String]()
    var hID = [UUID]()
    var uuid = "4D7BC347-E708-453E-9C58-EBDF48FDB263"
    let rows = 5
    let columns = 2
    
    init() {
        getHabitRecord()
    }
    
    var body: some View {
        List{
            VStack {
                ForEach(0 ..< rows, id: \.self) { row in
                    HStack {
                        ForEach(0 ..< self.columns, id:\.self) { col in
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
                                HabitDetailView(isPresented: self.$showHabitDetailView, habID: self.stringToUUID(input: self.uuid))
                            }
                        }
                    }
                }
            }
            //            GridStack(rows: 5, columns: 2) { row, col in
            //
            //            }
        }
    }
    
    mutating func getHabitRecord() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let moc = delegate.persistentContainer.viewContext
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "HabitDB")
        fetchReq.sortDescriptors = [NSSortDescriptor.init(key: "time", ascending: false)]
        do {
            let result = try moc.fetch(fetchReq)
            for data in result as! [NSManagedObject] {
                let stringName = data.value(forKey: "name") as! String
                let uuId = data.value(forKey: "id") as! UUID
                name.append(stringName)
                hID.append(uuId)
                //print("\(hID)")
            }
        } catch {
            print("Failed to retrieve")
        }
    }
    
    //change string to UUID
    func stringToUUID(input: String) -> UUID {
        let getInput = UUID(uuidString: input)!
        return getInput
    }
    
}
