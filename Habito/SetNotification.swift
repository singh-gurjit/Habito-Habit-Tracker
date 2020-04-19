//
//  SetNotification.swift
//  Habito
//
//  Created by Gurjit Singh on 18/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

struct Notification {
    var title: String
    var desc: String
}

class SetNotification {
    
    func setPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func setNotification(aTitle:String, aDesc:String, aDate: Date, aMode: [Int]) {
        let content = UNMutableNotificationContent()
        content.title = aTitle
        content.subtitle = aDesc
        content.sound = UNNotificationSound.default
        
        //change date to 24 format
        let changedDate = changeDateto24Format(date: aDate)
        let arrayChangedDate = changedDate.components(separatedBy: ":")
        //date components
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        //set hour and minute for reminder
        dateComponents.hour = Int(arrayChangedDate[0])
        dateComponents.minute = Int(arrayChangedDate[1])
        //set multiple notifications
        for (index, element) in aMode.enumerated() {
            //increase element value by one
            let day = element + 1
            print("recieved day index \(index) element \(element) current day \(day)")
            //weekday
            dateComponents.weekday = day
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: true)
            
            // choose a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            // add our notification request
            //UNUserNotificationCenter.current().add(request)
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print(error!)
                } else {
                    print("Alarm on ...")
                }
            }
        }
        
    }
    
    func changeDateto24Format(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let newDateString = dateFormatter.string(from: date)
        print("New date from 12 hour: \(newDateString)")
        return newDateString
    }
}
