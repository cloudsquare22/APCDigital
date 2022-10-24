//
//  Calendar.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/08.
//  Copyright © 2020 shi-n. All rights reserved.
//

import Foundation
import UIKit
import PencilKit
import EventKit
import Algorithms
import Logging

class APCDCalendar {
    var eventStore = EKEventStore()
    
    weak var base: ViewController? = nil

    let logger = Logger()
    
    init(base: ViewController?) {
        self.base = base
    }
    
    func exportFileAllPencilKitData() -> URL? {
        var result: URL? = nil
        let pages = Pages.selectAll()
        var pageDatas: [PageData] = []
        for page in pages {
            if let data = Pages.select(year: page.year, week: page.week) {
                logger.info("\(page.year)-\(page.week):\(data.count)")
                let pageData = PageData(year: page.year, week: page.week, data: data)
                pageDatas.append(pageData)
            }
        }
        logger.info("pageDatas:\(pageDatas.count)")
        let filename = "APCDigital_All_PencilKitData.apcd"
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

            result = URL(fileURLWithPath: documentsFileName)
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: pageDatas, requiringSecureCoding: false)
                logger.info("Data count:\(data.count)")
                try data.write(to: result!)
            }
            catch {
                logger.error(error.localizedDescription)
                result = nil
            }
        }
        return result
    }
    
    func importFileAllPencilKitData(url: URL) {
        var pageDatas: [PageData] = []
        do {
            let _ = url.startAccessingSecurityScopedResource()
            let readData = try Data(contentsOf: url)
            logger.info("Data count:\(readData.count)")
            pageDatas = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(readData) as! [PageData]
            logger.info("pageDatas:\(pageDatas.count)")
            for pageData in pageDatas {
                logger.info("upsert:\(pageData.year)-\(pageData.week)")
                Pages.upsert(year: pageData.year, week: pageData.week, page: pageData.data)
            }
        }
        catch {
            logger.error("読込異常")
            logger.error(error.localizedDescription)
        }
    }

    func export(fromDate: Date, toDate: Date) -> URL? {
        var result: URL? = nil
        
        print("Export start \(Date())")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0.0, y: 0.0, width: 1366.0, height: 1024.0), nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return result}

        var dateCurrent = fromDate
        while dateCurrent < toDate {
            autoreleasepool {
                let view = createWeeklyCalendar(date: dateCurrent)
                UIGraphicsBeginPDFPage()
                view.layer.render(in: pdfContext)
            }
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
            remainingView.text = APCDCalendarUtil.instance.countElapsedRemaining(day: dateComponentsWeek[day].date!)
            remainingView.font = UIFont.systemFont(ofSize: 10.0, weight: .semibold)
            remainingView.textColor = UIColor(named: "Basic Color Green")

            view.addSubview(dayView)
            view.addSubview(remainingView)
            self.addEvent(view: view, day: dateComponentsWeek[day], startPoint: CGFloat(dayX[day]))
        }
    }

    func addEvent(view: UIView, day: DateComponents, startPoint: CGFloat) {
        var dayOutPeriodEvent: [EKEvent] = []

        let movementSymmbolList: [String] = APCDCalendarUtil.instance.makeMovementSymmbolList()

        let eventArray = self.events(day: day)
        let nationalHoliday = self.base!.nationalHolidayCalendarName
        for event in eventArray {
            if event.calendar.title == nationalHoliday {
                view.addSubview(self.createHolidayView(event: event, startPoint: startPoint))
            }
            if self.base!.displayCalendars.contains(event.calendar.title) == true {
                if APCDCalendarUtil.instance.isEventFilter(event: event) == true {
                    continue
                }

                // add Location
                var title = APCDCalendarUtil.instance.addLocationEventTitle(event: event)!

                if event.isAllDay == false {
                    var startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
                    print(startDateComponents)
                    let endDateComponents = Calendar.current.dateComponents(in: .current, from: event.endDate)
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
                        
                        // 期間外エリア表示指定カレンダー処理
                        if self.base!.displayOutCalendars.contains(event.calendar.title) == true {
                            dayOutPeriodEvent.append(event)
                            continue
                        }

                        if startH < 6 && (endH < 6 || (endH <= 6 && endM == 0)) {
                            print("Out range")
                            dayOutPeriodEvent.append(event)
                            continue
                        }
                        else if startH < 6 , 6 <= endH {
                            startDateComponents.hour = 6
                            title = String(format: "%d:%02d〜", startH, startM) + title
                            print("start Out range")
                            print(startDateComponents)
                            startDate = Calendar.current.date(from: startDateComponents)!
                            print(startDate)
                            startLineHidden = true
                        }
                        else if startH <= 23, 0 <= endH, startDateComponents.day != endDateComponents.day {
                            if startH == 23, 30 <= startM {
                                print("Out range 23:30")
                                dayOutPeriodEvent.append(event)
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
                    view.addSubview(APCDCalendarUtil.instance.createScheduleView(title: title,
                                                                                 event: event,
                                                                                 startDate: startDate,
                                                                                 endDate: endDate,
                                                                                 startLineHidden: startLineHidden,
                                                                                 endLineHidden: endLineHidden,
                                                                                 movementSymmbolList: movementSymmbolList))
                }
                else {
                    dayOutPeriodEvent.append(event)
                }
            }
        }
        if dayOutPeriodEvent.isEmpty == false {
            let outPeriodView = self.createOutPeriodView(startPoint: startPoint)
            APCDCalendarUtil.instance.dispOutPeriod(label: outPeriodView,
                                                    events: dayOutPeriodEvent)
            view.addSubview(outPeriodView)
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
    
    func createOutPeriodView(startPoint: CGFloat) -> UILabel {
        let outPeriodView = UILabel(frame: CGRect(x: startPoint + 2.0, y: 107.0, width: 135.0, height: 50.0))
        outPeriodView.numberOfLines = 0
        outPeriodView.lineBreakMode = .byCharWrapping
        return outPeriodView
    }
    
    func createHolidayView(event: EKEvent, startPoint: CGFloat) -> UILabel {
        let holidayView = UILabel(frame: CGRect(x: startPoint + 39.0, y: 93.0, width: 99.0, height: 13.0))
        holidayView.text = event.title!
        holidayView.font = UIFont.systemFont(ofSize: 10.0, weight: .semibold)
        holidayView.textColor = UIColor(named: "Basic Color Green")
        holidayView.textAlignment = .right
        return holidayView
    }
    
    func createMonthlyCalrendar(view: UIView, monday: Date) {
        view.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 168, width: 145, height: 105), day: monday).view)
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: monday)
        view.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 273, width: 145, height: 105), day: nextMonth!, selectWeek: false).view)
    }
    
    func createPKCanvasView(view: UIView, dateComponentsWeek: [DateComponents]) {
        if let page = Pages.select(year: dateComponentsWeek[0].yearForWeekOfYear!, week: dateComponentsWeek[0].weekOfYear!) {
            autoreleasepool {
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
        }
        else {
            print("select no page")
        }
        
    }

}

class PageData: NSObject, NSCoding {
    var year: Int
    var week: Int
    var data: Data
    
    init(year: Int, week:Int, data: Data) {
        self.year = year
        self.week = week
        self.data = data
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(year, forKey: "year")
        coder.encode(week, forKey: "week")
        coder.encode(data, forKey: "data")
    }
    
    required init?(coder: NSCoder) {
        self.year = coder.decodeInteger(forKey: "year")
        self.week = coder.decodeInteger(forKey: "week")
        self.data = coder.decodeObject(forKey: "data") as? Data ?? Data()
    }
}

