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

        // 1週間分のイベントリストを日毎に展開
        var dayOfEKEventList: [[EKEvent]] = .init(repeating: [], count: 7)
        for event in eKEventList {
            if event.isAllDay == true {
                var startDate = event.startDate! < base.pageMonday ? base.pageMonday : event.startDate!
                let endDate = event.endDate!
                while startDate <= endDate {
                    let startDateComponents = Calendar.current.dateComponents(in: .current, from: startDate)
                    print(startDateComponents.weekday!)
                    let copyEvent = event.copy() as! EKEvent
                    copyEvent.startDate = startDate
                    dayOfEKEventList[startDateComponents.weekendStartMonday - 1].append(copyEvent)
                    if startDateComponents.weekday! == 1 {
                        break
                    }
                    startDate = startDate + TimeInterval(24 * 60 * 60)
                }
            }
            else {
                let startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
                dayOfEKEventList[startDateComponents.weekendStartMonday - 1].append(event)
            }
        }
        
        // イベント追加
        for index in 0..<7 {
            APCDCalendarUtil.instance.addEvent(eKEventList: dayOfEKEventList[index], view: self, base: base)
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
