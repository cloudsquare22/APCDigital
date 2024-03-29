//
//  ViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/07/03.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit
import PencilKit
import EventKit
import Logging

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var pKCanvasView: RapPKCanvasView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var logview: UITextView!
    
    var toolPicker: PKToolPicker!
    
    var pageMonday = Date()
    enum PageMondayDirection {
        case today
        case next
        case back
    }
    var days: [Int] = []

    var weekDaysDateComponents: [DateComponents] = []
    
    var scheduleViews: [(x: Double, y: Double, w: Double, h: Double, event: EKEvent)] = []
    
    var eventStore = EKEventStore()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)

    static let matching = DateComponents(weekday: 2)
    
    var memoryLogs: [String] = []
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    let logger = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.info()

        checkAuthorization()
        
        menuView.isHidden = true
        pKCanvasView.drawingPolicy = .pencilOnly
        pKCanvasView.isOpaque = false
        pKCanvasView.backgroundColor = .clear
        pKCanvasView.overrideUserInterfaceStyle = .light
        pKCanvasView.isRulerActive = false
        
        let tapPKCanvasView = UITapGestureRecognizer(target: self, action: #selector(self.tapPKCanvasView(sender:)))
        tapPKCanvasView.numberOfTapsRequired = 1
        pKCanvasView.addGestureRecognizer(tapPKCanvasView)
        
        let longPressPKCanvasView = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressPKCanvasView(sender:)))
        longPressPKCanvasView.minimumPressDuration = 0.6
        pKCanvasView.addGestureRecognizer(longPressPKCanvasView)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeft(sender:)))
        swipeLeft.direction = .left
        pKCanvasView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight(sender:)))
        swipeRight.direction = .right
        pKCanvasView.addGestureRecognizer(swipeRight)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeUp(sender:)))
        swipeUp.direction = .up
        pKCanvasView.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeDown(sender:)))
        swipeDown.direction = .down
        pKCanvasView.addGestureRecognizer(swipeDown)

        print(pKCanvasView.gestureRecognizers!)

        self.setPageMonday(direction: .today)

        self.dispPencilCase()
        
        self.logview.isHidden = true
        
        logger.info()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.info()
        print("-^--^-")
        print("pencil")
        print(PKInkingTool.InkType.pencil.defaultWidth)
        print(PKInkingTool.InkType.pencil.validWidthRange)
        print("maker")
        print(PKInkingTool.InkType.marker.defaultWidth)
        print(PKInkingTool.InkType.marker.validWidthRange)
        print("pen")
        print(PKInkingTool.InkType.pen.defaultWidth)
        print(PKInkingTool.InkType.pen.validWidthRange)
        print("crayon")
        print(PKInkingTool.InkType.crayon.defaultWidth)
        print(PKInkingTool.InkType.crayon.validWidthRange)
        print("fountainPen")
        print(PKInkingTool.InkType.fountainPen.defaultWidth)
        print(PKInkingTool.InkType.fountainPen.validWidthRange)
        print("monoline")
        print(PKInkingTool.InkType.monoline.defaultWidth)
        print(PKInkingTool.InkType.monoline.validWidthRange)
        print("watercolor")
        print(PKInkingTool.InkType.watercolor.defaultWidth)
        print(PKInkingTool.InkType.watercolor.validWidthRange)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.info()

        self.pKCanvasView.becomeFirstResponder()
        self.updateDays()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.info()
    }
    
    func setPageMonday(direction: PageMondayDirection) {
        logger.info()
        switch direction {
        case .today:
            var dateComponents = Calendar.current.dateComponents(in: .current, from: Date.now)
            dateComponents.hour = 0
            dateComponents.minute = 0
            dateComponents.second = 0
            dateComponents.nanosecond = 0
            print(dateComponents)
            pageMonday = dateComponents.date!
            if dateComponents.weekday != 2 {
                pageMonday = Calendar.current.nextDate(after: pageMonday, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .backward)!
            }
        case .next:
            pageMonday = Calendar.current.nextDate(after: pageMonday, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .forward)!
        case .back:
            pageMonday = Calendar.current.nextDate(after: pageMonday, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .backward)!
        }
    }
    
    @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
        logger.info()
        self.pageUpsert()
        self.setPageMonday(direction: .next)
        self.updateDays()
    }

    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        logger.info()
        self.pageUpsert()
        self.setPageMonday(direction: .back)
        self.updateDays()
    }

    @objc func swipeUp(sender: UISwipeGestureRecognizer) {
        logger.info()
        menuView.isHidden.toggle()
    }

    @objc func swipeDown(sender: UISwipeGestureRecognizer) {
        logger.info()
        self.pageUpsert()
        self.setPageMonday(direction: .today)
        self.updateDays()
    }

    @objc func tapPKCanvasView(sender: UITapGestureRecognizer) {
        logger.info()
        let point = sender.location(in: self.pKCanvasView)
        if (1170.0 < point.x) && (point.x < 1170.0 + 145.0) && (31.0 < point.y) && (point.y < 31.0 + 87.0 + 21.0) {
            logger.info("Year Monthly calendar")
            if let yearCalendarViewController = storyBoard.instantiateViewController(withIdentifier: "YearCalendarView") as? YearCalendarViewController {
                yearCalendarViewController.viewController = self
                self.setPopoverPresentationController(size: CGSize(width: 475, height: 460),
                                                      rect: CGRect(x: 1170.0 + 145.0 / 2, y: 31.0 + 87.0, width: 1, height: 1),
                                                      controller: yearCalendarViewController)
                present(yearCalendarViewController, animated: false, completion: nil)
            }
        }
        if (1170.0 < point.x) && (point.x < 1170.0 + 145.0) && (168.0 < point.y) && (point.y < 168.0 + (105.0 * 2)) {
            logger.info("Touch Monthly calendar")
            if let selectJumpDayViewController = storyBoard.instantiateViewController(withIdentifier: "SelectJumpDayView") as? SelectJumpDayViewController {
                selectJumpDayViewController.viewController = self
                self.setPopoverPresentationController(size: CGSize(width: 300, height: 300),
                                                      rect: CGRect(x: 1170.0, y: 168.0 + 105.0, width: 1, height: 1),
                                                      controller: selectJumpDayViewController)
                present(selectJumpDayViewController, animated: false, completion: nil)
            }

        }
    }
    
    @objc func longPressPKCanvasView(sender: UILongPressGestureRecognizer) {
        logger.info()

        guard sender.state == UIGestureRecognizer.State.began else {
            return
        }
        
        let point = sender.location(in: self.pKCanvasView)
        
        var events: [EKEvent] = []
        for scheduleView in scheduleViews {
            if scheduleView.event.calendar.type != .calDAV {
                continue
            }
            if scheduleView.x <= point.x &&
                point.x <= scheduleView.x + scheduleView.w &&
                scheduleView.y <= point.y &&
                point.y <= scheduleView.y + scheduleView.h {
                events.append(scheduleView.event)
            }
        }
        print("count:\(events.count)")
        if events.count > 0 {
            let alert = UIAlertController(title: "Event Action", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "* New events *", style: .default, handler: { _ in
                self.dispEditScheduleView(point: point)
            }))
            for event in events {
                alert.addAction(UIAlertAction(title: event.title, style: .default, handler: { _ in
                    self.openEditScheduleView(event: event)
                }))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                print("cancel")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.dispEditScheduleView(point: point)
        }
    }
    
    func openEditScheduleView(event: EKEvent) {
        print(event.title!)
        print(event.calendar.type.rawValue)
        guard  event.calendar.type == .calDAV else {
            return
        }
        let editScheduleViewController = storyBoard.instantiateViewController(withIdentifier: "EditScheduleView") as? EditScheduleViewController
        if let controller = editScheduleViewController {
            controller.viewController = self
            controller.startDate = event.startDate
            controller.endDate = event.endDate
            controller.baseEvent = event
            controller.eventStore = self.eventStore
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 450),
                                                  rect: CGRect(x: self.view.frame.width / 2, y: 64, width: 1, height: 1),
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    func dispEditScheduleView(point: CGPoint) {
        var weekDayIndex = -1

        // タップポイントから曜日を決定
        for index in 0..<7 {
            if APCDCalendarUtil.instance.weekDayIndexX[index].start <= point.x &&
                point.x <= APCDCalendarUtil.instance.weekDayIndexX[index].end {
                weekDayIndex = index
            }
        }
        
        logger.info("weekDayIndex: \(weekDayIndex)")
        guard weekDayIndex != -1 else {
            return
        }

        let pointH = ((point.y - 169.0) / 45.5) + 6
        var startH = Int(pointH)
        if point.y < 169 {
            startH = 0
        }
        var startM = 0
        if pointH > CGFloat(startH) + 0.5 {
            startM = 30
        }
        var startDateComponents = Calendar.current.dateComponents(in: .current, from: pageMonday + Double(86400 * weekDayIndex))
        startDateComponents.hour = startH
        startDateComponents.minute = startM        
        let editScheduleViewController = storyBoard.instantiateViewController(withIdentifier: "EditScheduleView") as? EditScheduleViewController
        if let controller = editScheduleViewController {
            controller.viewController = self
            controller.startDate = Calendar.current.date(from: startDateComponents)
            controller.endDate = controller.startDate! + (60 * 60)
            if startH == 0 {
                controller.allday = true
            }
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 450),
                                                  rect: CGRect(x: self.view.frame.width / 2, y: 64, width: 1, height: 1),
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }

    func updateDays() {
        logger.info()
        
        self.scheduleViews = []
        
        // Data Initial
        self.setWeekDaysDateComponents(monday: pageMonday)
        APCDData.instance.loadData()
        
        // Main Area
        self.dispPKDrawing()
        self.dispEvent()
        
        // Right Side
        self.dispMonthLabel()
        self.dispMonthlyCalendar()
        self.dispWeekOfYear()
        
        logger.info("scheduleViews:\(self.scheduleViews.count)")
    }
        
    func setWeekDaysDateComponents(monday: Date) {
        self.weekDaysDateComponents = []
        for index in 0..<7 {
            let dateComponentsDay = Calendar.current.dateComponents(in: .current, from: monday + TimeInterval((86400 * index)))
            self.weekDaysDateComponents.append(dateComponentsDay)
        }
    }
    
    func pageUpsert() {
        logger.info()
        let saveWeek = Calendar.current.dateComponents(in: .current, from: pageMonday)
        logger.info("year: \(saveWeek.yearForWeekOfYear!) week:\(saveWeek.weekOfYear!)")
        Pages.upsert(year: saveWeek.yearForWeekOfYear!, week: saveWeek.weekOfYear!, page: self.pKCanvasView.drawing.dataRepresentation())
    }
    
    func checkAuthorization() {
        logger.info()
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)

        if status == .fullAccess {
            logger.info("Access OK")
        }
        else if status == .notDetermined {
            eventStore.requestFullAccessToEvents(completion: { (granted, error) in
                if granted {
                    self.logger.info("Accessible")
                }
                else {
                    self.logger.info("Access denied")
                }
            })
        }
    }
    
    func addMemoryLogs(log: String) {
        self.memoryLogs.append(log)
        if self.memoryLogs.count > 50 {
            self.memoryLogs.removeFirst()
        }
        self.logview.text = self.memoryLogs.joined(separator: "\n")
    }
        
    func dispPKDrawing() {
        logger.info()
        self.addMemoryLogs(log: #function)
        let monday = self.weekDaysDateComponents[WeekDay1stMonday.monday.rawValue]
        if let page = Pages.select(year: monday.yearForWeekOfYear!, week: monday.weekOfYear!) {
            logger.info("select page")
            self.addMemoryLogs(log: "select year:\(monday.yearForWeekOfYear!) week:\(monday.weekOfYear!)")
            do {
                logger.info("Page count: \(page.count)")
                self.addMemoryLogs(log: "Page count: \(page.count)")
                Thread.sleep(forTimeInterval: 0.2)
                self.pKCanvasView.drawing = try PKDrawing(data: page)
                self.pKCanvasView.setNeedsDisplay()
                self.pKCanvasView.layoutIfNeeded()
                self.addMemoryLogs(log: "Set end.")
            }
            catch {
                let nserror = error as NSError
                self.addMemoryLogs(log: "catch:\(nserror)")
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        else {
            self.pKCanvasView.drawing = PKDrawing()
            logger.info("select no page")
            self.addMemoryLogs(log: "select no page.")
        }
        self.addMemoryLogs(log: #function + " end")
    }
    
    func dispEvent() {
        logger.info()
        self.calendarView.clearSchedule(base: self)
        self.calendarView.dispDayLabel(base: self)
        self.calendarView.dispReamingLabel(base: self)
        let eKEventList = self.getEvents()
        self.calendarView.dispSchedule(eKEventList: eKEventList, base: self)
    }
    
    func getEvents() -> [EKEvent] {
        var monday = self.weekDaysDateComponents[WeekDay1stMonday.monday.rawValue]
        monday.hour = 0
        monday.minute = 0
        monday.second = 0
        monday.nanosecond = 0
        var sunday = self.weekDaysDateComponents[WeekDay1stMonday.sunday.rawValue]
        sunday.hour = 23
        sunday.minute = 59
        sunday.second = 59
        sunday.nanosecond = 999
        let predicate = eventStore.predicateForEvents(withStart: monday.date!, end: sunday.date!, calendars: nil)
        let eventArray = eventStore.events(matching: predicate)
        return eventArray
    }
    
    func dispMonthLabel() {
        logger.info()
        let monday = self.weekDaysDateComponents[WeekDay1stMonday.monday.rawValue]
        let sunday = self.weekDaysDateComponents[WeekDay1stMonday.sunday.rawValue]
        
        let monthView = APCDCalendarUtil.instance.createMonthView(monday: monday, sunday: sunday)
        self.calendarView.addSubview(monthView)

        let fromView = APCDCalendarUtil.instance.createFromView(monday: monday)
        self.calendarView.addSubview(fromView)

        let toView = APCDCalendarUtil.instance.createToView(sunday: sunday)
        self.calendarView.addSubview(toView)
    }
    
    func dispMonthlyCalendar() {
        logger.info()
        self.calendarView.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 168, width: 145, height: 105), day: self.pageMonday).view)
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self.pageMonday)
        self.calendarView.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 273, width: 145, height: 105), day: nextMonth!, selectWeek: false).view)
    }
    
    func dispWeekOfYear() {
        logger.info()
        let weekOfYearView = APCDCalendarUtil.instance.createWeekOfYearView(monday: self.weekDaysDateComponents[WeekDay1stMonday.monday.rawValue])
        self.calendarView.addSubview(weekOfYearView)
    }
    
    func dispPencilCase() {
        logger.info()
        self.view.addSubview(PencilCaseView(frame: CGRect(x: 540, y: 16, width: 640, height: 35), pKCanvasView: self.pKCanvasView))
    }
    
    @IBAction func tapCalendarSelect(_ sender: Any) {
        logger.info()
        let calendarSelectViewController = storyBoard.instantiateViewController(withIdentifier: "CalendarSelectView") as? CalendarSelectViewController
        if let controller = calendarSelectViewController {
            controller.viewController = self
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 800),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    @IBAction func tapAbout(_ sender: Any) {
        logger.info()
        let aboutViewController = storyBoard.instantiateViewController(withIdentifier: "AboutView") as? AboutViewController
        if let controller = aboutViewController {
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 800),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    @IBAction func tapCalendar(_ sender: Any) {
        logger.info()
        let interval = self.pageMonday.timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow:\(interval)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func tapEditEvents(_ sender: Any) {
        logger.info()
        let editEventsViewController = storyBoard.instantiateViewController(withIdentifier: "EditEventsView") as? EditEventsViewController
        if let controller = editEventsViewController {
            controller.viewController = self
            self.setPopoverPresentationController(size: CGSize(width: 800, height: 800),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }

    @IBAction func tapArchive(_ sender: Any) {
        logger.info()
        let pKDataViewController = storyBoard.instantiateViewController(withIdentifier: "PKDataView") as? PKDataViewController
        if let controller = pKDataViewController {
            controller.viewController = self
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 800),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    @IBAction func tapExport(_ sender: Any) {
        logger.info()
        let exportViewController = storyBoard.instantiateViewController(withIdentifier: "ExportView") as? ExportViewController
        if let controller = exportViewController {
            controller.viewController = self
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 500),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    @IBAction func tapSetting(_ sender: Any) {
        logger.info()
        let settingViewController = storyBoard.instantiateViewController(withIdentifier: "SettingView") as? SettingViewController
        if let controller = settingViewController {
            controller.viewController = self
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 800),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    @IBAction func tapFilter(_ sender: Any) {
        logger.info()
        let eventFilterViewController = storyBoard.instantiateViewController(withIdentifier: "EventFilterView") as? EventFilterViewController
        if let controller = eventFilterViewController {
            controller.viewController = self
            self.setPopoverPresentationController(size: CGSize(width: 800, height: 800),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    @IBAction func tapLogsView(_ sender: Any) {
        self.logview.isHidden.toggle()
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func setPopoverPresentationController(size: CGSize, rect: CGRect, controller: UIViewController) {
        logger.info()
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.sourceView = self.view
        controller.popoverPresentationController?.sourceRect = rect
        controller.popoverPresentationController?.permittedArrowDirections = .any
        controller.popoverPresentationController?.delegate = self
        controller.preferredContentSize = size
    }
}

extension ViewController: PKToolPickerObserver {
    func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
        logger.info(toolPicker.description)
    }
    
}
