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

    func clearSchedule() {
        logger.info()
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func dispSchedule(eventArray: [EKEvent], base: ViewController) {
        logger.info("eventArray Count: \(eventArray.count)")
        logger.debug("eventArray: \(eventArray) base: \(base)")
        var dayOutPeriod: [[String]] = .init(repeating: [], count: 8)
        let movementSymmbolList: [String] = APCDCalendarUtil.instance.makeMovementSymmbolList()
        let eventFilters: [(calendar: String, filterString: String)] = EventFilter.selectAll()
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
                dispNationalHoliday(event: event, base: base)
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
                var title = APCDCalendarUtil.instance.addLocationEventTitle(event: event)!

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
                            let outSchedule = String(format: "%d:%02d ", startH, startM) + title
                            dayOutPeriod[startDateComponents.weekday!].append(outSchedule)
                            continue
                        }
                        else if startH < 6 , 6 <= endH {
                            startDateComponents.hour = 6
                            startDateComponents.minute = 0
                            title = String(format: "%d:%02d〜", startH, startM) + title
                            startDate = Calendar.current.date(from: startDateComponents)!
                            startLineHidden = true
                        }
                        else if startH <= 23, 0 <= endH, startDateComponents.day != endDateComponents.day {
                            if startH == 23, 30 <= startM {
                                let outSchedule = String(format: "%d:%02d ", startH, startM) + title
                                dayOutPeriod[startDateComponents.weekday!].append(outSchedule)
                                continue
                            }
                            else {
                                title = title + String(format: "\n〜%d:%02d", endH, endM)
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
                    self.addSubview(APCDCalendarUtil.instance.createScheduleView(title: title,
                                                                                 event: event,
                                                                                 startDate: startDate,
                                                                                 endDate: endDate,
                                                                                 startLineHidden: startLineHidden,
                                                                                 endLineHidden: endLineHidden,
                                                                                 movementSymmbolList: movementSymmbolList,
                                                                                 base: base))
                }
                else {
                    var startDate = event.startDate! < base.pageMonday ? base.pageMonday : event.startDate!
                    let endDate = event.endDate!
                    while startDate <= endDate {
                        let startDateComponents = Calendar.current.dateComponents(in: .current, from: startDate)
                        print(startDateComponents.weekday!)
                        let outSchedule = title
                        dayOutPeriod[startDateComponents.weekday!].append(outSchedule)
                        if startDateComponents.weekday! == 1 {
                            break
                        }
                        startDate = startDate + TimeInterval(24 * 60 * 60)
                    }
                }
            }
        }
        for index in 1...7 {
            if dayOutPeriod[index].isEmpty == false {
                print("dayOutPeriod weekday:\(index)")
                print(dayOutPeriod[index])
                self.dispOutSchedule(weekday: index, texts: dayOutPeriod[index], base: base)
            }
        }
    }
    
    func dispNationalHoliday(event: EKEvent, base: ViewController) {
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
    }
    
    func dispOutSchedule(weekday: Int, texts: [String], base: ViewController) {
        switch weekday {
        case 2:
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day1outPeriod, texts: texts)
        case 3:
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day2outPeriod, texts: texts)
        case 4:
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day3outPeriod, texts: texts)
        case 5:
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day4outPeriod, texts: texts)
        case 6:
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day5outPeriod, texts: texts)
        case 7:
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day6outPeriod, texts: texts)
        case 1:
            APCDCalendarUtil.instance.dispOutPeriod(label: base.day7outPeriod, texts: texts)
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
