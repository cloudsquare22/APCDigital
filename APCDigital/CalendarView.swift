//
//  CalendarView.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/07/05.
//  Copyright © 2020 shi-n. All rights reserved.
//

import Foundation
import UIKit

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
    
    override func draw(_ rect: CGRect) {
//        let rectangle = UIBezierPath(rect: CGRect(x: 100.0, y: 100.0, width: 300, height: 100))
//        UIColor(ciColor: .green).setStroke()
//        rectangle.lineWidth = 1.0
//        rectangle.stroke()
    }
}
