//
//  GridCalender.swift
//  Habito
//
//  Created by Gurjit Singh on 20/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import SwiftUI

struct GridCalender: View {
    let rows = 5
    let columns = 7
    let days = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    
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
                        Image(systemName: self.cell(row, column)).font(.largeTitle)
                    }
                }.padding(10)
            }
        }.frame(maxWidth: .infinity)
    }
    
    var cell:(Int, Int) -> String = { row, col in
        let result: String
        if row == 2 {
            result = "\((row * 7) + col).circle.fill"
        } else {
            result = "\((row * 7) + col).circle"
        }
        return result
    }
}
