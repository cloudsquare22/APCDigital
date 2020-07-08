//
//  CalendarView.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/07/05.
//  Copyright © 2020 shi-n. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class CalendarView: UIView {
    func lalala() {
        let scheduleView = ScheduleView(frame: CGRect(x: 55, y: 192, width: 140, height: 23))
        scheduleView.baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.3)
        self.addSubview(scheduleView)

//        let schedule = ScheduleView(frame: CGRect(x: 63, y: 193, width: 132, height: 23))
//
//        self.addSubview(schedule)
//        let scheduleBox = UIView(frame: CGRect(x: 100, y: 300, width: 100, height: 50))
//        scheduleBox.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.5)
//        self.addSubview(scheduleBox)
    }
    
    func clearSchedule() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func dispSchedule(eventArray: [EKEvent]) {
//        print(eventArray)
        for event in eventArray {
            if event.calendar.title == "work" || event.calendar.title == "oneself" || event.calendar.title == "FC Barcelona" {
                if event.isAllDay == false {
                    var startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
                    print(startDateComponents)
                    let endDateComponents = Calendar.current.dateComponents(in: .current, from: event.endDate)
                    print(endDateComponents)
                    
                    var startDate: Date = event.startDate
                    var startLineHidden = false
                    if let startH = startDateComponents.hour, let startM = startDateComponents.minute,
                        let endH = endDateComponents.hour, let endM = endDateComponents.minute {
                        if startH < 6 , endH < 6 {
                            print("Out range")
                            continue
                        }
                        if startH < 6 , 6 <= endH {
                            startDateComponents.hour = 6
                            event.title = String(format: "%d:%02d-", startH, startM) + event.title
                            print("start Out range")
                            print(startDateComponents)
                            startDate = Calendar.current.date(from: startDateComponents)!
                            print(startDate)
                            startLineHidden = true
                        }
                    }

                    print(startDateComponents.weekday!)
                    var x = 55.0
                    var widthAdd = 0.0
                    switch startDateComponents.weekday! {
                    case 2:
                        x = 55.0
                    case 3:
                        x = 55.0 + 148.0
                    case 4:
                        x = 55.0 + 148.0 * 2.0
                    case 5:
                        x = 55.0 + 148.0 * 3.0
                        widthAdd = 3.5
                    case 6:
                        x = 55.0 + 73 + 148.0 * 4.0
                    case 7:
                        x = 55.0 + 73 + 148.0 * 5.0
                    case 1:
                        x = 55.0 + 73 + 148.0 * 6.0
                        widthAdd = 3.5
                    default:
                        x = 0.0
                    }
                    var y: Double = 169.0 + 45.5 * Double(startDateComponents.hour! - 6)
                    if let minutes = startDateComponents.minute {
                        if minutes != 0 {
                            y = y + 45.5 * (Double(minutes) / Double(60))
                        }
                    }
                    print(y)
                    let diff = event.endDate.timeIntervalSince(startDate) / 900
                    let scheduleView = ScheduleView(frame: CGRect(x: x, y: y, width: 140.0 + widthAdd, height: 11.375 * diff))
//                    scheduleView.baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.3)
//                    scheduleView.baseView.backgroundColor = UIColor(cgColor: event.calendar.cgColor)
                    scheduleView.baseView.backgroundColor = UIColor(red: event.calendar.cgColor.components![0],
                                                                    green: event.calendar.cgColor.components![1],
                                                                    blue: event.calendar.cgColor.components![2],
                                                                    alpha: 0.3)
                    scheduleView.label.text = event.title
                    var minuteSFSymbol = "circle"
                    switch startDateComponents.minute {
                    case 0, 30:
                        minuteSFSymbol = "circle"
                    case 51, 52, 53, 54, 55, 56, 57, 58, 59:
                        minuteSFSymbol = "circle"
                    default:
                        minuteSFSymbol = String(startDateComponents.minute!) + ".circle"
                    }
                    if startLineHidden == true {
                        minuteSFSymbol = "arrowtriangle.down"
                    }
                    scheduleView.minute.image = UIImage(systemName: minuteSFSymbol)
                    
                    if event.title.hasPrefix("🚗") == true || event.title.hasPrefix("🚃") {
                        scheduleView.addLine(isMove: true, isStartLineHideen: startLineHidden)
                    }
                    else {
                        scheduleView.addLine(isMove: false, isStartLineHideen: startLineHidden)
                    }
                    print(event.calendar.cgColor.components)
                    self.addSubview(scheduleView)

                }
            }
        }
//        let scheduleView = ScheduleView(frame: CGRect(x: 55, y: 169, width: 140, height: 45.5))
//        scheduleView.baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.3)
//        let scheduleView2 = ScheduleView(frame: CGRect(x: 55, y: 214.5, width: 140, height: 45.5))
//        scheduleView2.baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.3)
//        let scheduleView3 = ScheduleView(frame: CGRect(x: 55, y: 260, width: 140, height: 45.5))
//        scheduleView3.baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.3)
//        let scheduleView4 = ScheduleView(frame: CGRect(x: 55, y: 305.5, width: 140, height: 45.5))
//        scheduleView4.baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.3)
//        let scheduleView5 = ScheduleView(frame: CGRect(x: 55, y: 351, width: 140, height: 45.5))
//        scheduleView5.baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.3)
//        let scheduleView6 = ScheduleView(frame: CGRect(x: 55, y: 396.5, width: 140, height: 45.5))
//        scheduleView6.baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.3)
//        self.addSubview(scheduleView)
//        self.addSubview(scheduleView2)
//        self.addSubview(scheduleView3)
//        self.addSubview(scheduleView4)
//        self.addSubview(scheduleView5)
//        self.addSubview(scheduleView6)
    }
    
    override func draw(_ rect: CGRect) {
//        let rectangle = UIBezierPath(rect: CGRect(x: 100.0, y: 100.0, width: 300, height: 100))
//        UIColor(ciColor: .green).setStroke()
//        rectangle.lineWidth = 1.0
//        rectangle.stroke()
    }
}
