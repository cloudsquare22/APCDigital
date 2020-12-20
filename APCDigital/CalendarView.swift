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
import Logging
import Algorithms

class CalendarView: UIView {
    let logger = Logger()

    var day1outPeriod: [String] = []
    var day2outPeriod: [String] = []
    var day3outPeriod: [String] = []
    var day4outPeriod: [String] = []
    var day5outPeriod: [String] = []
    var day6outPeriod: [String] = []
    var day7outPeriod: [String] = []

    func clearSchedule() {
        logger.info()
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func dispSchedule(eventArray: [EKEvent], base: ViewController) {
        logger.info("eventArray Count: \(eventArray.count)")
        logger.debug("eventArray: \(eventArray) base: \(base)")
        var movementSymmbolList: [String] = []
        if let symbols = UserDefaults.standard.string(forKey: "movementSymbols") {
            for symbol in symbols {
                movementSymmbolList.append(String(symbol))
            }
        }
        self.day1outPeriod = []
        self.day2outPeriod = []
        self.day3outPeriod = []
        self.day4outPeriod = []
        self.day5outPeriod = []
        self.day6outPeriod = []
        self.day7outPeriod = []
        base.day1Holiday.isHidden = true
        base.day2Holiday.isHidden = true
        base.day3Holiday.isHidden = true
        base.day4Holiday.isHidden = true
        base.day5Holiday.isHidden = true
        base.day6Holiday.isHidden = true
        base.day7Holiday.isHidden = true
        base.day1outPeriod.text = ""
        base.day2outPeriod.text = ""
        base.day3outPeriod.text = ""
        base.day4outPeriod.text = ""
        base.day5outPeriod.text = ""
        base.day6outPeriod.text = ""
        base.day7outPeriod.text = ""
        let nationalHoliday = base.nationalHolidayCalendarName
        for event in eventArray {
            if event.calendar.title == nationalHoliday {
                let startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
                if let title = event.title {
                    switch startDateComponents.weekday {
                    case 2:
                        base.day1Holiday.text = title
                        base.day1Holiday.isHidden = false
                    case 3:
                        base.day2Holiday.text = title
                        base.day2Holiday.isHidden = false
                    case 4:
                        base.day3Holiday.text = title
                        base.day3Holiday.isHidden = false
                    case 5:
                        base.day4Holiday.text = title
                        base.day4Holiday.isHidden = false
                    case 6:
                        base.day5Holiday.text = title
                        base.day5Holiday.isHidden = false
                    case 7:
                        base.day6Holiday.text = title
                        base.day6Holiday.isHidden = false
                    case 1:
                        base.day7Holiday.text = title
                        base.day7Holiday.isHidden = false
                    default:
                        break
                    }
                }
                continue
            }
            if base.displayCalendars.contains(event.calendar.title) == true {
//            if base.calendars.contains(event.calendar) == true {
//
//            if event.calendar.title == "work" || event.calendar.title == "oneself" || event.calendar.title == "FC Barcelona" || event.calendar.title == "2020 FIA Formula One World Championship Race Calendar" || event.calendar.title == "buy" {
                if event.calendar.title == "2020 FIA Formula One World Championship Race Calendar" {
                    if (event.title.contains("PRACTICE") == true) || (event.title.contains("QUALIFYING") == true) {
                        continue
                    }
                }
                if let location = event.structuredLocation?.title, location.isEmpty == false {
                    let locations = location.split(separator: "\n")
                    event.title = String(format: "%@(%@)", event.title, String(locations[0]))
                }

                if event.isAllDay == false {
                    var startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
                    var endDateComponents = Calendar.current.dateComponents(in: .current, from: event.endDate)

                    if base.days.contains(startDateComponents.day!) == false {
                        continue
                    }

                    var startDate: Date = event.startDate
                    var endDate: Date = event.endDate
                    var startLineHidden = false
                    var endLineHidden = false
                    if let startH = startDateComponents.hour, let startM = startDateComponents.minute,
                        let endH = endDateComponents.hour, let endM = endDateComponents.minute {
                        if startH < 6 && (endH < 6 || (endH <= 6 && endM == 0)) {
                            self.dispOutSchedule(startH: startH, startM: startM, weekday: startDateComponents.weekday!, event: event, base: base)
                            continue
                        }
                        else if startH < 6 , 6 <= endH {
                            startDateComponents.hour = 6
                            startDateComponents.minute = 0
                            event.title = String(format: "%d:%02d〜", startH, startM) + event.title
                            startDate = Calendar.current.date(from: startDateComponents)!
                            startLineHidden = true
                        }
                        else if startH <= 23, 0 <= endH, startDateComponents.day != endDateComponents.day {
                            if startH == 23, 30 <= startM {
                                self.dispOutSchedule(startH: startH, startM: startM, weekday: startDateComponents.weekday!, event: event, base: base)
                                continue
                            }
                            else {
                                event.title = event.title + String(format: "\n〜%d:%02d", endH, endM)
                                endDateComponents.day = startDateComponents.day
                                endDateComponents.hour = 23
                                endDateComponents.minute = 30
                                endDate = Calendar.current.date(from: endDateComponents)!
                                endLineHidden = true
                            }
                        }
                    }

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
                    let diff = endDate.timeIntervalSince(startDate) / 900
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
                    scheduleView.endTime.frame = CGRect(x: -8.0, y: 11.375 * diff - 2, width: 16, height: 16)
                    
                    if movementSymmbolList.contains(String(event.title.prefix(1))) == true {
                        scheduleView.addLine(isMove: true, isStartLineHidden: startLineHidden, isEndLineHidden: endLineHidden)
                    }
                    else {
                        scheduleView.addLine(isMove: false, isStartLineHidden: startLineHidden, isEndLineHidden: endLineHidden)
                    }
                    self.addSubview(scheduleView)

                }
                else {
                    let startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
                    if event.title != nil {
                        self.dispOutSchedule(weekday: startDateComponents.weekday!, event: event, base: base, isAllday: true)
                    }
                }
            }
        }
    }
    
    func dispOutPeriod(label: UILabel, texts: [String]) {
        logger.debug("label: \(label) texts: \(texts)")
        label.text = ""
        if texts.isEmpty == false {
            label.isHidden = false
            for (index, schedule) in texts.indexed() {
                label.text?.append(contentsOf: schedule)
                if index + 1 != texts.count {
                    label.text?.append(contentsOf: "\n")
                }
            }
//            label.sizeToFit()
        }
        else {
            label.isHidden = true
        }
    }
    
    func dispOutSchedule(startH: Int = 0, startM: Int = 0, weekday: Int, event: EKEvent, base: ViewController, isAllday: Bool = false) {
        var outSchedule = ""
        if isAllday == false {
            outSchedule = String(format: "%d:%02d〜", startH, startM) + event.title
        }
        else {
            outSchedule = event.title
        }
        switch weekday {
        case 2:
            self.day1outPeriod.append(outSchedule)
            dispOutPeriod(label: base.day1outPeriod, texts: day1outPeriod)
        case 3:
            self.day2outPeriod.append(outSchedule)
            dispOutPeriod(label: base.day2outPeriod, texts: day2outPeriod)
        case 4:
            self.day3outPeriod.append(outSchedule)
            dispOutPeriod(label: base.day3outPeriod, texts: day3outPeriod)
        case 5:
            self.day4outPeriod.append(outSchedule)
            dispOutPeriod(label: base.day4outPeriod, texts: day4outPeriod)
        case 6:
            self.day5outPeriod.append(outSchedule)
            dispOutPeriod(label: base.day5outPeriod, texts: day5outPeriod)
        case 7:
            self.day6outPeriod.append(outSchedule)
            dispOutPeriod(label: base.day6outPeriod, texts: day6outPeriod)
        case 1:
            self.day7outPeriod.append(outSchedule)
            dispOutPeriod(label: base.day7outPeriod, texts: day7outPeriod)
        default:
            break
        }
    }
    
    
    override func draw(_ rect: CGRect) {
//        let rectangle = UIBezierPath(rect: CGRect(x: 100.0, y: 100.0, width: 300, height: 100))
//        UIColor(ciColor: .green).setStroke()
//        rectangle.lineWidth = 1.0
//        rectangle.stroke()
    }
}
