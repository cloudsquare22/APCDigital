//
//  Calendar.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/08.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit
import PencilKit
import EventKit
import Algorithms

class APCDCalendar {
    var eventStore = EKEventStore()
    var displayCalendars: [String] = []

    func export(fromDate: Date, toDate: Date, displayCalendars: [String]) -> URL? {
        var result: URL? = nil
        self.displayCalendars = displayCalendars
        
        print("Export start \(Date())")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0.0, y: 0.0, width: 1366.0, height: 1024.0), nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return result}

        var dateCurrent = fromDate
        while dateCurrent < toDate {
            let view = createWeeklyCalendar(date: dateCurrent)
            UIGraphicsBeginPDFPage()
            view.layer.render(in: pdfContext)
            dateCurrent = Calendar.current.nextDate(after: dateCurrent, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .forward)!
        }
        
        UIGraphicsEndPDFContext()
        print("Export end \(Date())")
        
        let fromDateComponents = Calendar.current.dateComponents(in: .current, from: fromDate)
        let toDateComponents = Calendar.current.dateComponents(in: .current, from: toDate)
        let filename = String(format: "APCDigital_%04d%02d%02d-%04d%02d%02d.pdf",
                              fromDateComponents.year!, fromDateComponents.month!, fromDateComponents.day!,
                              toDateComponents.year!, toDateComponents.month!, toDateComponents.day!)


        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: documentDirectories)
                print(files)
                for file in files {
                    try FileManager.default.removeItem(atPath: documentDirectories + "/" + file)
                }
            }
            catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            let documentsFileName = documentDirectories + "/" + filename
            pdfData.write(toFile: documentsFileName, atomically: true)
            result = URL(fileURLWithPath: documentsFileName)
        }
        return result
    }
    
    func createWeeklyCalendar(date: Date) -> UIView {
        let weekday = Calendar.current.component(.weekday, from: date)
        var monday = date
        if weekday != 2 {
            monday = Calendar.current.nextDate(after: monday, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .backward)!
        }
        var dateComponentsWeek: [DateComponents] = []
        for index in 0..<7 {
            let dateComponentsDay = Calendar.current.dateComponents(in: .current, from: monday + TimeInterval((86400 * index)))
            dateComponentsWeek.append(dateComponentsDay)
        }
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1366.0, height: 1024.0))
        view.backgroundColor = .white
        let templateView = UIImageView(image: UIImage(named: "aptemplate"))
        templateView.frame = CGRect(x: 0.0, y: 0.0, width: 1366.0, height: 1024.0)
        templateView.contentMode = .scaleAspectFit
        view.addSubview(templateView)
        
        let month = UILabel(frame: CGRect(x: 1170.0, y: 31.0, width: 145.0, height: 87.0))
        if dateComponentsWeek.first!.month == dateComponentsWeek.last!.month {
            month.text = String(dateComponentsWeek.first!.month!)
        }
        else {
            month.text = String(dateComponentsWeek.first!.month!) + "/" + String(dateComponentsWeek.last!.month!)
        }
        month.font = UIFont.systemFont(ofSize: 48.0, weight: .semibold)
        month.textColor = UIColor(named: "Basic Color Green")
        month.textAlignment = .center
        view.addSubview(month)
        
        let from = UILabel(frame: CGRect(x: 1170.0, y: 105.0, width: 145.0, height: 21.0))
        from.text = Calendar.shortMonthSymbols(local: Locale(identifier: "en"))[dateComponentsWeek.first!.month! - 1].uppercased() + " " + String(dateComponentsWeek.first!.day!)
        from.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        from.textColor = UIColor(named: "Basic Color Green")
        from.textAlignment = .center
        view.addSubview(from)

        let to = UILabel(frame: CGRect(x: 1170.0, y: 124.0, width: 145.0, height: 21.0))
        to.text = "to " + Calendar.shortMonthSymbols(local: Locale(identifier: "en"))[dateComponentsWeek.last!.month! - 1].uppercased() + " " + String(dateComponentsWeek.last!.month!)
        to.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        to.textColor = UIColor(named: "Basic Color Green")
        to.textAlignment = .center
        view.addSubview(to)

        let weekOfYear = UILabel(frame: CGRect(x: 1170.0, y: 380.0, width: 145.0, height: 16.0))
        weekOfYear.text = String(Calendar.current.component(.weekOfYear, from: monday)) + " week"
        weekOfYear.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        weekOfYear.textColor = UIColor(named: "Basic Color Green")
        weekOfYear.textAlignment = .center
        view.addSubview(weekOfYear)

        createDay(view: view, dateComponentsWeek: dateComponentsWeek)
        createMonthlyCalrendar(view: view, monday: monday)
        createPKCanvasView(view: view, dateComponentsWeek: dateComponentsWeek)
        return view
    }
    
    func createDay(view: UIView, dateComponentsWeek: [DateComponents]) {
        let dayX = [60.0, 208.0, 356.0, 504.0, 725.0, 872.0, 1020.0]
        for day in 0..<7 {
            let dayView = UILabel(frame: CGRect(x: dayX[day], y: 80.0, width: 32.0, height: 29.0))
            dayView.text = String(dateComponentsWeek[day].day!)
            dayView.font = UIFont.systemFont(ofSize: 24.0, weight: .semibold)
            dayView.textColor = UIColor(named: "Basic Color Green")

            let remainingView = UILabel(frame: CGRect(x: dayX[day] + 32.0, y: 83.0, width: 99.0, height: 13.0))
            remainingView.text = countElapsedRemaining(day: dateComponentsWeek[day].date!)
            remainingView.font = UIFont.systemFont(ofSize: 10.0, weight: .semibold)
            remainingView.textColor = UIColor(named: "Basic Color Green")

            view.addSubview(dayView)
            view.addSubview(remainingView)
            self.addEvent(view: view, day: dateComponentsWeek[day], startPoint: CGFloat(dayX[day]))
        }
    }

    func countElapsedRemaining(day: Date) -> String {
        var result = ""
        let dayComponentes = Calendar.current.dateComponents(in: .current, from: day)
        let dateYearFirst = Calendar.current.date(from: DateComponents(year: dayComponentes.year, month: 1, day: 1))!
        let dateYearEnd = Calendar.current.date(from: DateComponents(year: dayComponentes.year, month: 12, day: 31))!

        let elapsed = Calendar.current.dateComponents([.day], from: dateYearFirst, to: day)
        let remaining = Calendar.current.dateComponents([.day], from: day, to: dateYearEnd)
        
        result = String(format: "%d-%d", elapsed.day! + 1, remaining.day!)
        return result
    }
    
    func addEvent(view: UIView, day: DateComponents, startPoint: CGFloat) {
        var dayOutPeriod: [String] = []

        var movementSymmbolList: [String] = []
        if let symbols = UserDefaults.standard.string(forKey: "movementSymbols") {
            for symbol in symbols {
                movementSymmbolList.append(String(symbol))
            }
        }

        let eventArray = self.events(day: day)
        for event in eventArray {
            if event.calendar.title == "日本の祝日" {
                view.addSubview(self.createHolidayView(event: event, startPoint: startPoint))
            }
            if self.displayCalendars.contains(event.calendar.title) == true {
                // Special
                if event.calendar.title == "2020 FIA Formula One World Championship Race Calendar" {
                    if event.title.contains("PRACTICE") == true {
                        continue
                    }
                }

                // add Location
                if let location = event.structuredLocation?.title, location.isEmpty == false {
                    let locations = location.split(separator: "\n")
                    event.title = String(format: "%@(%@)", event.title, String(locations[0]))
                }

                if event.isAllDay == false {
                    var startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
                    print(startDateComponents)
                    var endDateComponents = Calendar.current.dateComponents(in: .current, from: event.endDate)
                    print(endDateComponents)
                    
                    if day.day != startDateComponents.day {
                        continue
                    }

                    var startDate: Date = event.startDate
                    var endDate: Date = event.endDate
                    var startLineHidden = false
                    var endLineHidden = false
                    if let startH = startDateComponents.hour, let startM = startDateComponents.minute,
                        let endH = endDateComponents.hour, let endM = endDateComponents.minute {
                        if startH < 6 && (endH < 6 || (endH <= 6 && endM == 0)) {
                            print("Out range")
                            let outSchedule = String(format: "%d:%02d〜", startH, startM) + event.title
                            dayOutPeriod.append(outSchedule)
                            continue
                        }
                        else if startH < 6 , 6 <= endH {
                            startDateComponents.hour = 6
                            event.title = String(format: "%d:%02d〜", startH, startM) + event.title
                            print("start Out range")
                            print(startDateComponents)
                            startDate = Calendar.current.date(from: startDateComponents)!
                            print(startDate)
                            startLineHidden = true
                        }
                        else if startH <= 23, 0 <= endH, startDateComponents.day != endDateComponents.day {
                            if startH == 23, 30 <= startM {
                                print("Out range 23:30")
                                let outSchedule = String(format: "%d:%02d〜", startH, startM) + event.title
                                dayOutPeriod.append(outSchedule)
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
                    let diff = endDate.timeIntervalSince(startDate) / 900
                    let scheduleView = ScheduleView(frame: CGRect(x: x, y: y, width: 140.0 + widthAdd, height: 11.375 * diff))
                    scheduleView.baseView.backgroundColor = UIColor(red: event.calendar.cgColor.components![0],
                                                                    green: event.calendar.cgColor.components![1],
                                                                    blue: event.calendar.cgColor.components![2],
                                                                    alpha: 0.3)
                    scheduleView.label.text = event.title
                    scheduleView.label.numberOfLines = 0
                    var labelFrame = scheduleView.label.frame
                    scheduleView.label.sizeToFit()
                    labelFrame.size.height = scheduleView.label.frame.size.height
                    scheduleView.label.frame = labelFrame
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
                    view.addSubview(scheduleView)
                }
                else {
                    if let outSchedule = event.title {
                        dayOutPeriod.append(outSchedule)
                    }
                }
            }
        }
        if dayOutPeriod.isEmpty == false {
            view.addSubview(self.createOutPeriod(texts: dayOutPeriod, startPoint: startPoint))
        }
    }
    
    func events(day: DateComponents) -> [EKEvent] {
        var startDateComponents = Calendar.current.dateComponents(in: .current, from: day.date!)
        startDateComponents.hour = 0
        startDateComponents.minute = 0
        startDateComponents.second = 0
        startDateComponents.nanosecond = 0
        var endDateComponents = Calendar.current.dateComponents(in: .current, from: day.date!)
        endDateComponents.hour = 23
        endDateComponents.minute = 59
        endDateComponents.second = 59
        endDateComponents.nanosecond = 0
        let predicate = eventStore.predicateForEvents(withStart: startDateComponents.date!, end: endDateComponents.date!, calendars: nil)
        let eventArray = eventStore.events(matching: predicate)
        return eventArray
    }
    
    func createHolidayView(event: EKEvent, startPoint: CGFloat) -> UILabel {
        let holidayView = UILabel(frame: CGRect(x: startPoint + 39.0, y: 93.0, width: 99.0, height: 13.0))
        holidayView.text = event.title!
        holidayView.font = UIFont.systemFont(ofSize: 10.0, weight: .semibold)
        holidayView.textColor = UIColor(named: "Basic Color Green")
        holidayView.textAlignment = .right
        return holidayView
    }
    
    func createOutPeriod(texts: [String], startPoint: CGFloat) -> UILabel {
//        print("--^--\(texts)")
        let outPeriod = UILabel(frame: CGRect(x: startPoint + 2.0, y: 107.0, width: 135.0, height: 50.0))
        outPeriod.font = UIFont.systemFont(ofSize: 10.0, weight: .medium)
        outPeriod.textColor = .black
        outPeriod.backgroundColor = UIColor(named: "Basic Color Gray Light")
        outPeriod.textAlignment = .left
        outPeriod.text = ""
        outPeriod.numberOfLines = 0
        for (index, schedule) in texts.indexed() {
            outPeriod.text?.append(contentsOf: schedule)
            if index + 1 != texts.count {
                outPeriod.text?.append(contentsOf: "\n")
            }
        }
        return outPeriod
    }
    
    func createMonthlyCalrendar(view: UIView, monday: Date) {
        view.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 168, width: 145, height: 105), day: monday).view)
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: monday)
        view.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 273, width: 145, height: 105), day: nextMonth!, selectWeek: false).view)
    }
    
    func createPKCanvasView(view: UIView, dateComponentsWeek: [DateComponents]) {
        if let page = Pages.select(year: dateComponentsWeek[0].year!, week: dateComponentsWeek[0].weekOfYear!) {
            do {
                print(page.count)
                let drawaing = try PKDrawing(data: page).image(from: CGRect(x: 0.0, y: 0.0, width: 1366.0, height: 1024.0), scale: 3.0)
                let image = UIImageView(image: drawaing)
                image.frame = CGRect(x: 0.0, y: 0.0, width: 1366.0, height: 1024.0)
                image.contentMode = .scaleAspectFit
                view.addSubview(image)
            }
            catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        else {
            print("select no page")
        }
        
    }

}
