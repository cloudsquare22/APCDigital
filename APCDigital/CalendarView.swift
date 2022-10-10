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
    
    func hiddenBaseParts(base: ViewController) {
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
    }
    
    func dispSchedule(eKEventList: [EKEvent], base: ViewController) {
        logger.info("eventArray Count: \(eKEventList.count)")
        logger.debug("eventArray: \(eKEventList) base: \(base)")
        var dayOutPeriodEvent: [[EKEvent]] = .init(repeating: [], count: 7)
        var dayOutPeriodLavel = [base.day1outPeriod,
                                 base.day2outPeriod,
                                 base.day3outPeriod,
                                 base.day4outPeriod,
                                 base.day5outPeriod,
                                 base.day6outPeriod,
                                 base.day7outPeriod]
        let movementSymmbolList: [String] = APCDCalendarUtil.instance.makeMovementSymmbolList()
        let eventFilters: [(calendar: String, filterString: String)] = EventFilter.selectAll()
        self.hiddenBaseParts(base: base)
        let nationalHoliday = base.nationalHolidayCalendarName
        for event in eKEventList {
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
                        
                        // 期間外エリア表示指定カレンダー処理
                        if base.displayOutCalendars.contains(event.calendar.title) == true {
                            dayOutPeriodEvent[startDateComponents.weekendStartMonday - 1].append(event)
                            continue
                        }
                        
                        if startH < 6 && (endH < 6 || (endH <= 6 && endM == 0)) {
                            dayOutPeriodEvent[startDateComponents.weekendStartMonday - 1].append(event)
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
                                dayOutPeriodEvent[startDateComponents.weekendStartMonday - 1].append(event)
                                continue
                            }
                            else {
                                title = title + String(format: "\n〜%d:%02d", endH, endM)
                                endDate = self.createDayoverEnd(startDateComponents: startDateComponents)
                                endLineHidden = true
                            }
                        }
                        else if endH == 23, endM > 30, startDateComponents.day == endDateComponents.day {
                            title = title + String(format: "\n〜%d:%02d", endH, endM)
                            endDate = self.createDayoverEnd(startDateComponents: startDateComponents)
                            endLineHidden = true
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
                        dayOutPeriodEvent[startDateComponents.weekendStartMonday - 1].append(event)
                        if startDateComponents.weekday! == 1 {
                            break
                        }
                        startDate = startDate + TimeInterval(24 * 60 * 60)
                    }
                }
            }
        }
        // 期間外ラベル表示
        for index in 0..<7 {
            if dayOutPeriodEvent[index].isEmpty == false {
                print("dayOutPeriod weekday:\(index)")
                print(dayOutPeriodEvent[index])
                APCDCalendarUtil.instance.dispOutPeriod(label: dayOutPeriodLavel[index]!,
                                                        events: dayOutPeriodEvent[index])
            }
        }
    }
    
    func createDayoverEnd(startDateComponents: DateComponents) -> Date {
        var endDateComponents: DateComponents = startDateComponents
        endDateComponents.hour = 23
        endDateComponents.minute = 30
        return Calendar.current.date(from: endDateComponents)!
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
        
    override func draw(_ rect: CGRect) {
//        let rectangle = UIBezierPath(rect: CGRect(x: 100.0, y: 100.0, width: 300, height: 100))
//        UIColor(ciColor: .green).setStroke()
//        rectangle.lineWidth = 1.0
//        rectangle.stroke()
    }
}

extension CGColor {
    func getRGBInt() -> (Int, Int, Int) {
        var result = (0, 0, 0)
        // RGB抽出、255形式変換
        if let rgba = self.components {
            let r = Int(floor(rgba[0] * 100) / 100 * 255)
            print("r:\(r)")
            let g = Int(floor(rgba[1] * 100) / 100 * 255)
            print("g:\(g)")
            let b = Int(floor(rgba[2] * 100) / 100 * 255)
            print("b:\(b)")
            result = (r, g, b)
        }
        return result
    }
}

extension DateComponents {
    var weekendStartMonday: Int {
        var result = 1
        if let weekday = self.weekday {
            result = weekday == 1 ? 7 : weekday - 1
        }
        return result
    }
}
