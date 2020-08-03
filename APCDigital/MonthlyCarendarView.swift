//
//  MonthlyCarendarView.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/01.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class MonthlyCarendarView {
    let view: UIView
    let day: Date
    var selectWeek: Bool
    let selectWeekMonday: Date
    
    init(frame: CGRect, day: Date, selectWeek: Bool = true) {
        self.view = UIView(frame: frame)
        self.day = day
        self.selectWeek = selectWeek
        let weekday = Calendar.current.component(.weekday, from: day)
        if weekday != 2 {
            let matching = DateComponents(weekday: 2)
            selectWeekMonday = Calendar.current.nextDate(after: day, matching: matching, matchingPolicy: .nextTime, direction: .backward)!
        }
        else {
            selectWeekMonday = day
        }
        createCalendar()
    }
    
    func createCalendar() {
        let dayDateComponents = Calendar.current.dateComponents(in: .current, from: day)
        let mondayDateComponents = Calendar.current.dateComponents(in: .current, from: selectWeekMonday)

        let lineColor = UIColor(red: 165.0 / 255.0, green: 165.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0).cgColor
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 145, height: 1.0)
        topBorder.backgroundColor = lineColor
        self.view.layer.addSublayer(topBorder)
        let middleBorder = CALayer()
        middleBorder.frame = CGRect(x: 0, y: 16, width: 145, height: 1.0)
        middleBorder.backgroundColor = lineColor
        self.view.layer.addSublayer(middleBorder)
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: 105, width: 145, height: 1.0)
        bottomBorder.backgroundColor = lineColor
        self.view.layer.addSublayer(bottomBorder)
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: 0, y: 0, width: 1.0, height: 105)
        leftBorder.backgroundColor = lineColor
        self.view.layer.addSublayer(leftBorder)
        let rightBorder = CALayer()
        rightBorder.frame = CGRect(x: 145, y: 0, width: 1.0, height: 105)
        rightBorder.backgroundColor = lineColor
        self.view.layer.addSublayer(rightBorder)

        let baseColor = UIColor(red: 0.0, green: 143.0 / 255.0 , blue: 0.0, alpha: 1.0)
        let mmyy = UILabel(frame: CGRect(x: 1.0, y: 1.0, width: 144.0, height: 15.0))
        let monthText = String("\(Calendar.current.shortStandaloneMonthSymbols[dayDateComponents.month! - 1].uppercased()) \(dayDateComponents.year!)")
        mmyy.text = monthText
        mmyy.font = UIFont.systemFont(ofSize: 9.0)
        mmyy.textAlignment = .center
        mmyy.textColor = baseColor
        mmyy.backgroundColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
        self.view.addSubview(mmyy)
        
        let weekname = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
        for index in 0..<7 {
            var ajust: CGFloat = 0.0
            switch index {
            case 0, 2 :
                ajust = 2.0
            default:
                ajust = 1.0
            }
            let weeknameView = UIStackView(frame: CGRect(x: 4.0 + ajust + (20.0 * CGFloat(index)),
                                                         y: 20.0,
                                                         width: 20.0,
                                                         height: 15.0))
            let first = UILabel(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: 10.0,
                                              height: 15.0))
            first.text = String(weekname[index].prefix(1))
            first.font = UIFont.systemFont(ofSize: 9.0)
            first.textAlignment = .right
            first.textColor = .black
            let end = UILabel(frame: CGRect(x: 9,
                                            y: 2.0,
                                            width: 10.0,
                                            height: 13.0))
            end.text = String(weekname[index].suffix(1))
            end.font = UIFont.systemFont(ofSize: 7.0)
            end.textAlignment = .left
            end.textColor = .black
            weeknameView.addSubview(first)
            weeknameView.addSubview(end)
            self.view.addSubview(weeknameView)
        }
        var firstDateComponents = dayDateComponents
        firstDateComponents.day = 1
        firstDateComponents = Calendar.current.dateComponents(in: .current, from: Calendar.current.date(from: firstDateComponents)!)
        print("--^-- \(firstDateComponents)")
        var countDateComponents = DateComponents()
        countDateComponents.year = firstDateComponents.year
        countDateComponents.month = firstDateComponents.month! + 1
        countDateComponents.day = 0
        let dayCount = Calendar.current.component(.day, from: Calendar.current.date(from: countDateComponents)!)
        print("--^-- \(dayCount)")
        
        let weekday = firstDateComponents.weekday!
        var weekdayIndex = weekday - 1 == 0 ? 6 : weekday - 2
        var weekIndex = 0
        for day in 1...dayCount {
            if (self.selectWeek == true) && (day == mondayDateComponents.day!) {
                let weekBackView = UIView(frame: CGRect(x: 1,
                                                        y: 34 + (11.5 * CGFloat(weekIndex)),
                                                        width: 144,
                                                        height: 9))
                weekBackView.backgroundColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
                self.view.addSubview(weekBackView)
            }
            let dayView = UILabel(frame: CGRect(x: 4.0 + (20.0 * CGFloat(weekdayIndex)),
                                                y: 31.5 + (11.5 * CGFloat(weekIndex)),
                                            width: 20,
                                            height: 15))
            dayView.text = String(day)
            dayView.font = UIFont.systemFont(ofSize: 9.0)
            dayView.textAlignment = .center
            dayView.textColor = baseColor
            self.view.addSubview(dayView)
            if weekdayIndex + 1 > 6 {
                weekdayIndex = 0
                weekIndex = weekIndex + 1
            }
            else {
                weekdayIndex = weekdayIndex + 1
            }
        }
        if (self.selectWeek == true) && (weekdayIndex != 0) && ((dayCount - (weekdayIndex - 1)) == mondayDateComponents.day!) {
            var day = 1
            for index in weekdayIndex...6 {
                let dayView = UILabel(frame: CGRect(x: 4.0 + (20.0 * CGFloat(index)),
                                                    y: 31.5 + (11.5 * CGFloat(weekIndex)),
                                                width: 20,
                                                height: 15))
                dayView.text = String(day)
                dayView.font = UIFont.systemFont(ofSize: 9.0)
                dayView.textAlignment = .center
                dayView.textColor = baseColor
                self.view.addSubview(dayView)
                day = day + 1
            }
        }
    }

}
