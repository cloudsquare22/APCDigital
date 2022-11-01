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

    func clearSchedule(base: ViewController) {
        logger.info()
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func dispSchedule(eKEventList: [EKEvent], base: ViewController) {
        logger.info("eventArray Count: \(eKEventList.count)")
        logger.debug("eventArray: \(eKEventList) base: \(base)")
        var dayOutPeriodEvent: [[EKEvent]] = .init(repeating: [], count: 7)

        // 1週間分のイベントリストを日毎に展開
        var dayOfEKEventList: [[EKEvent]] = .init(repeating: [], count: 7)
        for event in eKEventList {
            var startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
            dayOfEKEventList[startDateComponents.weekendStartMonday - 1].append(event)
        }
        
        for event in eKEventList {
            if event.calendar.title == APCDData.instance.nationalHoliday {
                let holidayView = APCDCalendarUtil.instance.createHolidayView(event: event)
                self.addSubview(holidayView)
                continue
            }
            if APCDData.instance.displayCalendars.contains(event.calendar.title) == true {
                if APCDCalendarUtil.instance.isEventFilter(event: event) == true {
                    continue
                }

                // add Location
                var title = APCDCalendarUtil.instance.addLocationEventTitle(event: event)!

                if event.isAllDay == false {
                    var startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
                    let endDateComponents = Calendar.current.dateComponents(in: .current, from: event.endDate)

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
                        if APCDData.instance.displayOutCalendars.contains(event.calendar.title) == true {
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
                                title = APCDCalendarUtil.instance.createDayoverTitle(title: title, endH: endH, endM: endM)
                                endDate = APCDCalendarUtil.instance.createDayoverEnd(startDateComponents: startDateComponents)
                                endLineHidden = true
                            }
                        }
                        else if endH == 23, endM > 30, startDateComponents.day == endDateComponents.day {
                            title = APCDCalendarUtil.instance.createDayoverTitle(title: title, endH: endH, endM: endM)
                            endDate = APCDCalendarUtil.instance.createDayoverEnd(startDateComponents: startDateComponents)
                            endLineHidden = true
                        }
                    }
                    self.addSubview(APCDCalendarUtil.instance.createScheduleView(title: title,
                                                                                 event: event,
                                                                                 startDate: startDate,
                                                                                 endDate: endDate,
                                                                                 startLineHidden: startLineHidden,
                                                                                 endLineHidden: endLineHidden))
                    let scheduleView = self.subviews.last!
                    let x = scheduleView.frame.origin.x
                    let y = scheduleView.frame.origin.y
                    let w = scheduleView.frame.width
                    let h = scheduleView.frame.height
                    base.scheduleViews.append((x: x, y: y, w: w, h: h, event: event))
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
                let dayOutPeriodLavel = APCDCalendarUtil.instance.dispOutPeriod(events: dayOutPeriodEvent[index])
                self.addSubview(dayOutPeriodLavel)
                let x = dayOutPeriodLavel.frame.origin.x
                let y = dayOutPeriodLavel.frame.origin.y
                let w = dayOutPeriodLavel.frame.size.width
                let h = dayOutPeriodLavel.frame.size.height
                for event in dayOutPeriodEvent[index] {
                    base.scheduleViews.append((x: x, y: y, w: w, h: h, event: event))
                }
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
