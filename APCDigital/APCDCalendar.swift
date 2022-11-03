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
        
        let monthView = APCDCalendarUtil.instance.createMonthView(monday: dateComponentsWeek.first!, sunday: dateComponentsWeek.last!)
        view.addSubview(monthView)
        
        let fromView = APCDCalendarUtil.instance.createFromView(monday: dateComponentsWeek.first!)
        view.addSubview(fromView)

        let toView = APCDCalendarUtil.instance.createToView(sunday: dateComponentsWeek.last!)
        view.addSubview(toView)

        let weekOfYear = UILabel(frame: CGRect(x: 1170.0, y: 380.0, width: 145.0, height: 16.0))
        weekOfYear.text = APCDCalendarUtil.instance.createWeekOfYearString(monday: monday)
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
        for day in 0..<7 {
            let dayView = APCDCalendarUtil.instance.createDayView(dateComponents: dateComponentsWeek[day])

            let remainingView = APCDCalendarUtil.instance.crateRemainingView(dateComponents: dateComponentsWeek[day])

            view.addSubview(dayView)
            view.addSubview(remainingView)

            let eKEventList = self.events(day: dateComponentsWeek[day])
            var dayOfEKEventList: [EKEvent] = []
            for event in eKEventList {
                if event.isAllDay == true {
                    let copyEvent = event.copy() as! EKEvent
                    copyEvent.startDate = dateComponentsWeek[day].date
                    dayOfEKEventList.append(copyEvent)
                }
                else {
                    dayOfEKEventList.append(event)
                }
            }
            APCDCalendarUtil.instance.addEvent(day: dateComponentsWeek[day].day!, eKEventList: dayOfEKEventList, view: view)
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

