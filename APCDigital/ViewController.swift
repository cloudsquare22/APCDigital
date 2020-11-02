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
    @IBOutlet weak var pKCanvasView: PKCanvasView!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day1: UILabel!
    @IBOutlet weak var day2: UILabel!
    @IBOutlet weak var day3: UILabel!
    @IBOutlet weak var day4: UILabel!
    @IBOutlet weak var day5: UILabel!
    @IBOutlet weak var day6: UILabel!
    @IBOutlet weak var day7: UILabel!
    @IBOutlet weak var fromDay: UILabel!
    @IBOutlet weak var toDay: UILabel!
    @IBOutlet weak var weekOfYear: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var day1outPeriod: UILabel!
    @IBOutlet weak var day2outPeriod: UILabel!
    @IBOutlet weak var day3outPeriod: UILabel!
    @IBOutlet weak var day4outPeriod: UILabel!
    @IBOutlet weak var day5outPeriod: UILabel!
    @IBOutlet weak var day6outPeriod: UILabel!
    @IBOutlet weak var day7outPeriod: UILabel!
    @IBOutlet weak var day1Holiday: UILabel!
    @IBOutlet weak var day2Holiday: UILabel!
    @IBOutlet weak var day3Holiday: UILabel!
    @IBOutlet weak var day4Holiday: UILabel!
    @IBOutlet weak var day5Holiday: UILabel!
    @IBOutlet weak var day6Holiday: UILabel!
    @IBOutlet weak var day7Holiday: UILabel!
    @IBOutlet weak var day1Remaining: UILabel!
    @IBOutlet weak var day2Remaining: UILabel!
    @IBOutlet weak var day3Remaining: UILabel!
    @IBOutlet weak var day4Remaining: UILabel!
    @IBOutlet weak var day5Remaining: UILabel!
    @IBOutlet weak var day6Remaining: UILabel!
    @IBOutlet weak var day7Remaining: UILabel!
    
    var toolPicker: PKToolPicker!

    var pageMonday = Date()
    var days: [Int] = []
    var calendars: [EKCalendar] = []
    var displayCalendars: [String] = []
    
    var eventStore = EKEventStore()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)

    static let matching = DateComponents(weekday: 2)

//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    let logger = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.info()

        checkAuthorization()
        
        menuView.isHidden = true
        if #available(iOS 14.0, *) {
            pKCanvasView.drawingPolicy = .pencilOnly
        }
        else {
            pKCanvasView.allowsFingerDrawing = false
        }
        pKCanvasView.isOpaque = false
        pKCanvasView.backgroundColor = .clear
        pKCanvasView.overrideUserInterfaceStyle = .light

        let tapPKCanvasView = UITapGestureRecognizer(target: self, action: #selector(self.tapPKCanvasView(sender:)))
        tapPKCanvasView.numberOfTapsRequired = 2
        pKCanvasView.addGestureRecognizer(tapPKCanvasView)
        
        let longPressPKCanvasView = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressPKCanvasView(sender:)))
        longPressPKCanvasView.minimumPressDuration = 0.5
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

        let weekday = Calendar.current.component(.weekday, from: Date())

        if weekday != 2 {
            pageMonday = Calendar.current.nextDate(after: pageMonday, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .backward)!
        }
        else {
            pageMonday = Date()
        }
//        updateDays()
        logger.info()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.info()

        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
            toolPicker.showsDrawingPolicyControls = false
        }
        else {
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)
        }
        toolPicker.addObserver(pKCanvasView)
        toolPicker.addObserver(self)
        toolPicker.setVisible(true, forFirstResponder: pKCanvasView)
        toolPicker.overrideUserInterfaceStyle = .light
        pKCanvasView.becomeFirstResponder()
        logger.info("PKToolPicker Set")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.info()

//        if #available(iOS 14.0, *) {
//            toolPicker = PKToolPicker()
//            toolPicker.showsDrawingPolicyControls = false
//        }
//        else {
//            let window = parent?.view.window
//            toolPicker = PKToolPicker.shared(for: window!)
//        }
//        toolPicker.addObserver(pKCanvasView)
//        toolPicker.addObserver(self)
//        toolPicker.setVisible(true, forFirstResponder: pKCanvasView)
//        toolPicker.overrideUserInterfaceStyle = .light
//        pKCanvasView.becomeFirstResponder()
//        logger.info("PKToolPicker Set")
        
        updateDays()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.info()
//        self.pageUpsert()
    }
    
    
    func updateCalendars() {
        logger.info()
        var nationalHoliday = "日本の祝日"
        if let title = UserDefaults.standard.string(forKey: "nationalHoliday") {
            nationalHoliday = title
        }
        let calendarAll = eventStore.calendars(for: .event)
        self.calendars = []
        for calendar in calendarAll {
            switch calendar.type {
            case .local, .calDAV,
                 .subscription where calendar.title != nationalHoliday:
                self.calendars.append(calendar)
            default:
                break
            }
        }
        self.calendars.sort() {
            $0.title < $1.title
        }
        
        if let displays = UserDefaults.standard.stringArray(forKey: "displayCalendars") {
            self.displayCalendars = displays
        }
        else {
            for calendar in self.calendars {
                self.displayCalendars.append(calendar.title)
            }
        }
    }

    @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
        logger.info()
        pageUpsert()
        
        pageMonday = Calendar.current.nextDate(after: pageMonday, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .forward)!
        updateDays()
    }

    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        logger.info()
        pageUpsert()

        pageMonday = Calendar.current.nextDate(after: pageMonday, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .backward)!
        updateDays()
    }

    @objc func swipeUp(sender: UISwipeGestureRecognizer) {
        logger.info()
    }

    @objc func swipeDown(sender: UISwipeGestureRecognizer) {
        logger.info()
        pageUpsert()

        pageMonday = Date()
        let weekday = Calendar.current.component(.weekday, from: pageMonday)
        if weekday != 2 {
            pageMonday = Calendar.current.nextDate(after: pageMonday, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .backward)!
        }
        else {
            pageMonday = Date()
        }
        updateDays()
    }

    @objc func tapPKCanvasView(sender: UITapGestureRecognizer) {
        logger.info()
        let point = sender.location(in: self.pKCanvasView)
        if (1170.0 < point.x) && (point.x < 1170.0 + 145.0) && (168.0 < point.y) && (point.y < 168.0 + (105.0 * 2)) {
            logger.info("Touch Monthly calendar")
            let selectJumpDayViewController = storyBoard.instantiateViewController(withIdentifier: "SelectJumpDayView") as? SelectJumpDayViewController
            if let controller = selectJumpDayViewController {
                controller.viewController = self
                self.setPopoverPresentationController(size: CGSize(width: 300, height: 300),
                                                      rect: CGRect(x: 1170.0, y: 168.0 + 105.0, width: 1, height: 1),
                                                      controller: controller)
                present(controller, animated: false, completion: nil)
            }

        }
        else {
            menuView.isHidden.toggle()
        }
    }
    
    @objc func longPressPKCanvasView(sender: UILongPressGestureRecognizer) {
        logger.info()
        let point = sender.location(in: self.pKCanvasView)
        
        var weekDayIndex = -1
        let weekDayIndexX: [CGFloat] = [55.0, 203.0, 351.0, 499.0, 647.0, 720.0, 868.0, 1016.0, 1164.0]
        switch point.x {
        case weekDayIndexX[0]..<weekDayIndexX[1]:
            weekDayIndex = 0
        case weekDayIndexX[1]..<weekDayIndexX[2]:
            weekDayIndex = 1
        case weekDayIndexX[2]..<weekDayIndexX[3]:
            weekDayIndex = 2
        case weekDayIndexX[3]..<weekDayIndexX[4]:
            weekDayIndex = 3
        case weekDayIndexX[5]..<weekDayIndexX[6]:
            weekDayIndex = 4
        case weekDayIndexX[6]..<weekDayIndexX[7]:
            weekDayIndex = 5
        case weekDayIndexX[7]..<weekDayIndexX[8]:
            weekDayIndex = 6
        default:
            break
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
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 400),
                                                  rect: CGRect(x: self.view.frame.width / 2, y: 10, width: 1, height: 1),
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }

    func updateDays() {
        logger.info()
        self.updateCalendars()
        
        let weekDays = self.getWeekDays()
        let dayLabels = [self.day1, self.day2, self.day3, self.day4, self.day5, self.day6, self.day7]

        let monday = Calendar.current.dateComponents(in: .current, from: pageMonday)
        let tuesday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 1))
        let wednesday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 2))
        let thursday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 3))
        let friday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 4))
        let saturday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 5))
        let sunday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 6))
        
        self.days = []
        for weekday in 0..<7 {
            let dateComponents = Calendar.current.dateComponents(in: .current, from: weekDays[weekday])
            dayLabels[weekday]?.text = String(dateComponents.day!)
            self.days.append(dateComponents.day!)
        }
//        self.day1.text = String(monday.day!)
//        self.day2.text = String(tuesday.day!)
//        self.day3.text = String(wednesday.day!)
//        self.day4.text = String(thursday.day!)
//        self.day5.text = String(friday.day!)
//        self.day6.text = String(saturday.day!)
//        self.day7.text = String(sunday.day!)
//        self.days = []
//        self.days.append(monday.day!)
//        self.days.append(tuesday.day!)
//        self.days.append(wednesday.day!)
//        self.days.append(thursday.day!)
//        self.days.append(friday.day!)
//        self.days.append(saturday.day!)
//        self.days.append(sunday.day!)
        if monday.month! == sunday.month! {
            self.month.text = String(monday.month!)
        }
        else {
            self.month.text = String(monday.month!) + "/" + String(sunday.month!)
        }
        self.fromDay.text = Calendar.current.standaloneMonthSymbols[monday.month! - 1].uppercased() + " " + String(monday.day!)
        self.toDay.text = "to " + Calendar.current.standaloneMonthSymbols[sunday.month! - 1].uppercased() + " " + String(sunday.day!)
        self.weekOfYear.text = String(Calendar.current.component(.weekOfYear, from: pageMonday)) + " week"

        self.day1Remaining.text = countElapsedRemaining(day: pageMonday)
        self.day2Remaining.text = countElapsedRemaining(day: pageMonday + (86400 * 1))
        self.day3Remaining.text = countElapsedRemaining(day: pageMonday + (86400 * 2))
        self.day4Remaining.text = countElapsedRemaining(day: pageMonday + (86400 * 3))
        self.day5Remaining.text = countElapsedRemaining(day: pageMonday + (86400 * 4))
        self.day6Remaining.text = countElapsedRemaining(day: pageMonday + (86400 * 5))
        self.day7Remaining.text = countElapsedRemaining(day: pageMonday + (86400 * 6))

        if let page = Pages.select(year: monday.year!, week: monday.weekOfYear!) {
            logger.info("select page")
            do {
                logger.info("Page count: \(page.count)")
                self.pKCanvasView.drawing = try PKDrawing(data: page)
            }
            catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        else {
            self.pKCanvasView.drawing = PKDrawing()
            logger.info("select no page")
        }
        
        var startDateComponents = Calendar.current.dateComponents(in: .current, from: pageMonday)
        startDateComponents.hour = 0
        startDateComponents.minute = 0
        startDateComponents.second = 0
        startDateComponents.nanosecond = 0
        var endDateComponents = Calendar.current.dateComponents(in: .current, from: pageMonday  + (86400 * 6))
        endDateComponents.hour = 23
        endDateComponents.minute = 59
        endDateComponents.second = 59
        endDateComponents.nanosecond = 0
        calendarView.clearSchedule()

        let predicate = eventStore.predicateForEvents(withStart: startDateComponents.date!, end: endDateComponents.date!, calendars: nil)
        let eventArray = eventStore.events(matching: predicate)
        
        calendarView.dispSchedule(eventArray: eventArray, base: self)
        self.dispMonthlyCalendar()
    }
    
    func getWeekDays() -> [Date] {
        var result: [Date] = []
        for weekday in 0..<7 {
            result.append(pageMonday  + TimeInterval((86400 * weekday)))
        }
        return result
    }
    
    func pageUpsert() {
        logger.info()
        let saveWeek = Calendar.current.dateComponents(in: .current, from: pageMonday)
        logger.info("year: \(saveWeek.year!) week:\(saveWeek.weekOfYear!)")
        Pages.upsert(year: saveWeek.year!, week: saveWeek.weekOfYear!, page: self.pKCanvasView.drawing.dataRepresentation())
    }
    
    func checkAuthorization() {
        logger.info()
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)

        if status == .authorized {
            logger.info("Access OK")
        }
        else if status == .notDetermined {
            eventStore.requestAccess(to: EKEntityType.event) { (granted, error) in
                if granted {
                    self.logger.info("Accessible")
                }
                else {
                    self.logger.info("Access denied")
                }
            }
        }
    }
    
    func countElapsedRemaining(day: Date) -> String {
        logger.info("day: \(day.debugDescription)")
        var result = ""
        let dayComponentes = Calendar.current.dateComponents(in: .current, from: day)
        let dateYearFirst = Calendar.current.date(from: DateComponents(year: dayComponentes.year, month: 1, day: 1))!
        let dateYearEnd = Calendar.current.date(from: DateComponents(year: dayComponentes.year, month: 12, day: 31))!

        let elapsed = Calendar.current.dateComponents([.day], from: dateYearFirst, to: day)
        let remaining = Calendar.current.dateComponents([.day], from: day, to: dateYearEnd)
        
        result = String(format: "%d-%d", elapsed.day! + 1, remaining.day!)
        return result
    }
    
    func dispMonthlyCalendar() {
        logger.info()
        self.calendarView.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 168, width: 145, height: 105), day: self.pageMonday).view)
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self.pageMonday)
        self.calendarView.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 273, width: 145, height: 105), day: nextMonth!, selectWeek: false).view)
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
        if let url = URL(string: "calshow:") {
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
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 800),
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
    
    @IBAction func tapXmark(_ sender: Any) {
        logger.info()
        menuView.isHidden.toggle()
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
