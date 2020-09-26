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

class CalendarView: UIView {
    let logger = Logger()
    
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
        var day1outPeriod: [String] = []
        var day2outPeriod: [String] = []
        var day3outPeriod: [String] = []
        var day4outPeriod: [String] = []
        var day5outPeriod: [String] = []
        var day6outPeriod: [String] = []
        var day7outPeriod: [String] = []
        base.day1Holiday.isHidden = true
        base.day2Holiday.isHidden = true
        base.day3Holiday.isHidden = true
        base.day4Holiday.isHidden = true
        base.day5Holiday.isHidden = true
        base.day6Holiday.isHidden = true
        base.day7Holiday.isHidden = true
        var nationalHoliday = "日本の祝日"
        if let title = UserDefaults.standard.string(forKey: "nationalHoliday") {
            nationalHoliday = title
        }
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
                    if event.title.contains("PRACTICE") == true {
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
                            let outSchedule = String(format: "%d:%02d〜", startH, startM) + event.title
                            switch startDateComponents.weekday {
                            case 2:
                                day1outPeriod.append(outSchedule)
                            case 3:
                                day2outPeriod.append(outSchedule)
                            case 4:
                                day3outPeriod.append(outSchedule)
                            case 5:
                                day4outPeriod.append(outSchedule)
                            case 6:
                                day5outPeriod.append(outSchedule)
                            case 7:
                                day6outPeriod.append(outSchedule)
                            case 1:
                                day7outPeriod.append(outSchedule)
                            default:
                                break
                            }
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
                                let outSchedule = String(format: "%d:%02d〜", startH, startM) + event.title
                                switch startDateComponents.weekday {
                                case 2:
                                    day1outPeriod.append(outSchedule)
                                case 3:
                                    day2outPeriod.append(outSchedule)
                                case 4:
                                    day3outPeriod.append(outSchedule)
                                case 5:
                                    day4outPeriod.append(outSchedule)
                                case 6:
                                    day5outPeriod.append(outSchedule)
                                case 7:
                                    day6outPeriod.append(outSchedule)
                                case 1:
                                    day7outPeriod.append(outSchedule)
                                default:
                                    break
                                }
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
                    if let outSchedule = event.title {
                        switch startDateComponents.weekday {
                        case 2:
                            day1outPeriod.append(outSchedule)
                        case 3:
                            day2outPeriod.append(outSchedule)
                        case 4:
                            day3outPeriod.append(outSchedule)
                        case 5:
                            day4outPeriod.append(outSchedule)
                        case 6:
                            day5outPeriod.append(outSchedule)
                        case 7:
                            day6outPeriod.append(outSchedule)
                        case 1:
                            day7outPeriod.append(outSchedule)
                        default:
                            break
                        }
                    }
                }
            }
            
            dispOutPeriod(label: base.day1outPeriod, texts: day1outPeriod)
            dispOutPeriod(label: base.day2outPeriod, texts: day2outPeriod)
            dispOutPeriod(label: base.day3outPeriod, texts: day3outPeriod)
            dispOutPeriod(label: base.day4outPeriod, texts: day4outPeriod)
            dispOutPeriod(label: base.day5outPeriod, texts: day5outPeriod)
            dispOutPeriod(label: base.day6outPeriod, texts: day6outPeriod)
            dispOutPeriod(label: base.day7outPeriod, texts: day7outPeriod)
        }
    }
    
    func dispOutPeriod(label: UILabel, texts: [String]) {
        logger.debug("label: \(label) texts: \(texts)")
        label.text = ""
        if texts.isEmpty == false {
            label.isHidden = false
            for (index, schedule) in texts.enumerated() {
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
    
    
    override func draw(_ rect: CGRect) {
//        let rectangle = UIBezierPath(rect: CGRect(x: 100.0, y: 100.0, width: 300, height: 100))
//        UIColor(ciColor: .green).setStroke()
//        rectangle.lineWidth = 1.0
//        rectangle.stroke()
    }
}
