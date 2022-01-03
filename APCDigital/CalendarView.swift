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
        let movementSymmbolList: [String] = APCDCalendarUtil.instance.makeMovementSymmbolList()
        let eventFilters: [(calendar: String, filterString: String)] = EventFilter.selectAll()
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
        base.day1outPeriod.isHidden = true
        base.day2outPeriod.isHidden = true
        base.day3outPeriod.isHidden = true
        base.day4outPeriod.isHidden = true
        base.day5outPeriod.isHidden = true
        base.day6outPeriod.isHidden = true
        base.day7outPeriod.isHidden = true
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
                let isEventFilter = eventFilters.contains(where: { (calendar, filterString) in
                    var result = false
                    if event.calendar.title == calendar {
                        if event.title.contains(filterString) == true {
                            result = true
                        }
                    }
                    return result
                })
                if isEventFilter == true {
                    continue
                }

                // add Location
                event.title = APCDCalendarUtil.instance.addLocationEventTitle(event: event)

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
                                endDateComponents.year = startDateComponents.year
                                endDateComponents.month = startDateComponents.month
                                endDateComponents.day = startDateComponents.day
                                endDateComponents.hour = 23
                                endDateComponents.minute = 30
                                endDate = Calendar.current.date(from: endDateComponents)!
                                endLineHidden = true
                            }
                        }
                    }
                    self.addSubview(APCDCalendarUtil.instance.createScheduleView(event: event,
                                                                                 startDate: startDate,
                                                                                 endDate: endDate,
                                                                                 startLineHidden: startLineHidden,
                                                                                 endLineHidden: endLineHidden,
                                                                                 movementSymmbolList: movementSymmbolList))
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
    
    func dispOutSchedule(startH: Int = 0, startM: Int = 0, weekday: Int, event: EKEvent, base: ViewController, isAllday: Bool = false) {
        var outSchedule = ""
        if isAllday == false {
//            outSchedule = String(format: "<font color=\"#008F00\">%d:%02d</font> ", startH, startM) + event.title
            outSchedule = String(format: "%d:%02d ", startH, startM) + event.title
        }
        else {
            outSchedule = event.title
        }
        switch weekday {
        case 2:
            self.day1outPeriod.append(outSchedule)
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day1outPeriod, texts: day1outPeriod)
        case 3:
            self.day2outPeriod.append(outSchedule)
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day2outPeriod, texts: day2outPeriod)
        case 4:
            self.day3outPeriod.append(outSchedule)
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day3outPeriod, texts: day3outPeriod)
        case 5:
            self.day4outPeriod.append(outSchedule)
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day4outPeriod, texts: day4outPeriod)
        case 6:
            self.day5outPeriod.append(outSchedule)
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day5outPeriod, texts: day5outPeriod)
        case 7:
            self.day6outPeriod.append(outSchedule)
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day6outPeriod, texts: day6outPeriod)
        case 1:
            self.day7outPeriod.append(outSchedule)
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day7outPeriod, texts: day7outPeriod)
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
