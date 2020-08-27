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
    
    var pageMonday = Date()
    var days: [Int] = []
    var calendars: [EKCalendar] = []
    var displayCalendars: [String] = []
    
    var eventStore = EKEventStore()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)

//    override var prefersStatusBarHidden: Bool {
//        return true
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAuthorization()
        
        menuView.isHidden = true

        pKCanvasView.allowsFingerDrawing = false
        pKCanvasView.isOpaque = false
        pKCanvasView.backgroundColor = .clear
        pKCanvasView.overrideUserInterfaceStyle = .light

        let tapPKCanvasView = UITapGestureRecognizer(target: self, action: #selector(self.tapPKCanvasView(sender:)))
        tapPKCanvasView.numberOfTapsRequired = 1
        pKCanvasView.addGestureRecognizer(tapPKCanvasView)
        
        let longPressPKCanvasView = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressPKCanvasView(sender:)))
        longPressPKCanvasView.minimumPressDuration = 0.3
        pKCanvasView.addGestureRecognizer(longPressPKCanvasView)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeft(sender:)))
        swipeLeft.direction = .left
        pKCanvasView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight(sender:)))
        swipeRight .direction = .right
        pKCanvasView.addGestureRecognizer(swipeRight)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeUp(sender:)))
        swipeUp .direction = .up
        pKCanvasView.addGestureRecognizer(swipeUp)

        print(Date().description(with: Calendar.current.locale))
        
        let weekday = Calendar.current.component(.weekday, from: Date())

        if weekday != 2 {
            let matching = DateComponents(weekday: 2)
            pageMonday = Calendar.current.nextDate(after: pageMonday, matching: matching, matchingPolicy: .nextTime, direction: .backward)!
        }
        else {
            pageMonday = Date()
        }
        updateDays()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")

        if let window = self.pKCanvasView.window {
            let toolPicker = PKToolPicker.shared(for: window)
            toolPicker?.addObserver(pKCanvasView)
            toolPicker?.setVisible(true, forFirstResponder: pKCanvasView)
            toolPicker?.overrideUserInterfaceStyle = .light
            pKCanvasView.becomeFirstResponder()
            print("PKToolPicker Set")
        }
        
        print(pageMonday)
        var startDateComponents = Calendar.current.dateComponents(in: .current, from: pageMonday)
        startDateComponents.hour = 0
        startDateComponents.minute = 0
        startDateComponents.second = 0
        startDateComponents.nanosecond = 0
//        var endDateComponents = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 6))
        var endDateComponents = Calendar.current.dateComponents(in: .current, from: pageMonday  + (86400 * 6))
        endDateComponents.hour = 23
        endDateComponents.minute = 59
        endDateComponents.second = 59
        endDateComponents.nanosecond = 0

        calendarView.clearSchedule()
        let predicate = eventStore.predicateForEvents(withStart: startDateComponents.date!, end: endDateComponents.date!, calendars: nil)
        let eventArray = eventStore.events(matching: predicate)
        calendarView.dispSchedule(eventArray: eventArray,base: self)

        self.dispMonthlyCalendar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
    }
    
    func updateCalendars() {
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
        self.calendars.sort() { (c1, c2) -> Bool in
            c1.title < c2.title
        }
        print(calendars)
        
        if let displays = UserDefaults.standard.stringArray(forKey: "displayCalendars") {
            print(displays)
            self.displayCalendars = displays
        }
        else {
            for calendar in self.calendars {
                self.displayCalendars.append(calendar.title)
            }
        }
    }

    @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
        pageUpsert()
        
        let matching = DateComponents(weekday: 2)
        pageMonday = Calendar.current.nextDate(after: pageMonday, matching: matching, matchingPolicy: .nextTime, direction: .forward)!
        updateDays()
    }

    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        pageUpsert()

        let matching = DateComponents(weekday: 2)
        pageMonday = Calendar.current.nextDate(after: pageMonday, matching: matching, matchingPolicy: .nextTime, direction: .backward)!
        updateDays()
    }

    @objc func swipeUp(sender: UISwipeGestureRecognizer) {
        pageUpsert()

        pageMonday = Date()
        let weekday = Calendar.current.component(.weekday, from: pageMonday)
        if weekday != 2 {
            let matching = DateComponents(weekday: 2)
            pageMonday = Calendar.current.nextDate(after: pageMonday, matching: matching, matchingPolicy: .nextTime, direction: .backward)!
        }
        else {
            pageMonday = Date()
        }
        updateDays()
    }

    @objc func tapPKCanvasView(sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.pKCanvasView)
        if (1170.0 < point.x) && (point.x < 1170.0 + 145.0) && (168.0 < point.y) && (point.y < 168.0 + (105.0 * 2)) {
            print("touch Monthly calendar")
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
        print("longPressPKCanvasView")
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
        print("weekDayIndex:\(weekDayIndex)")
        guard weekDayIndex != -1 else {
            return
        }

        var startH = Int((point.y - 169.0) / 45.5) + 6
        if point.y < 169 {
            startH = 0
        }
        print(startH)
        var startDateComponents = Calendar.current.dateComponents(in: .current, from: pageMonday + Double(86400 * weekDayIndex))
        startDateComponents.hour = startH
        startDateComponents.minute = 0
        print(startDateComponents)

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
        self.updateCalendars()

        let monday = Calendar.current.dateComponents(in: .current, from: pageMonday)
        let tuesday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 1))
        let wednesday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 2))
        let thursday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 3))
        let friday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 4))
        let saturday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 5))
        let sunday = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 6))
        print(monday)
        self.day1.text = String(monday.day!)
        self.day2.text = String(tuesday.day!)
        self.day3.text = String(wednesday.day!)
        self.day4.text = String(thursday.day!)
        self.day5.text = String(friday.day!)
        self.day6.text = String(saturday.day!)
        self.day7.text = String(sunday.day!)
        self.days = []
        self.days.append(monday.day!)
        self.days.append(tuesday.day!)
        self.days.append(wednesday.day!)
        self.days.append(thursday.day!)
        self.days.append(friday.day!)
        self.days.append(saturday.day!)
        self.days.append(sunday.day!)
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
            print("select page")
            do {
                print(page.count)
                self.pKCanvasView.drawing = try PKDrawing(data: page)
            }
            catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        else {
            self.pKCanvasView.drawing = PKDrawing()
            print("select no page")
        }
        
        print(pageMonday)
        var startDateComponents = Calendar.current.dateComponents(in: .current, from: pageMonday)
        startDateComponents.hour = 0
        startDateComponents.minute = 0
        startDateComponents.second = 0
        startDateComponents.nanosecond = 0
        //        var endDateComponents = Calendar.current.dateComponents(in: .current, from: pageMonday + (86400 * 6))
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
    
    func pageUpsert() {
        let saveWeek = Calendar.current.dateComponents(in: .current, from: pageMonday)
        Pages.upsert(year: saveWeek.year!, week: saveWeek.weekOfYear!, page: self.pKCanvasView.drawing.dataRepresentation())
    }
    
    func checkAuthorization() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)

        if status == .authorized {
            print("アクセスできます！！")
        }
        else if status == .notDetermined {
            // アクセス権限のアラートを送る。
            eventStore.requestAccess(to: EKEntityType.event) { (granted, error) in
                if granted { // 許可されたら
                    print("アクセス可能になりました。")
                }else { // 拒否されたら
                    print("アクセスが拒否されました。")
                }
            }
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
    
    func dispMonthlyCalendar() {
        self.calendarView.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 168, width: 145, height: 105), day: self.pageMonday).view)
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self.pageMonday)
        self.calendarView.addSubview(MonthlyCarendarView(frame: CGRect(x: 1170, y: 273, width: 145, height: 105), day: nextMonth!, selectWeek: false).view)
    }
    
    @IBAction func tapCalendarSelect(_ sender: Any) {
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
        let aboutViewController = storyBoard.instantiateViewController(withIdentifier: "AboutView") as? AboutViewController
        if let controller = aboutViewController {
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 800),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    @IBAction func tapCalendar(_ sender: Any) {
        if let url = URL(string: "calshow:") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func tapEditEvents(_ sender: Any) {
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
        let pKDataViewController = storyBoard.instantiateViewController(withIdentifier: "PKDataView") as? PKDataViewController
        if let controller = pKDataViewController {
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 800),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    @IBAction func tapExport(_ sender: Any) {
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
        let settingViewController = storyBoard.instantiateViewController(withIdentifier: "SettingView") as? SettingViewController
        if let controller = settingViewController {
            controller.viewController = self
            self.setPopoverPresentationController(size: CGSize(width: 600, height: 800),
                                                  rect: (sender as! UIButton).frame,
                                                  controller: controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func setPopoverPresentationController(size: CGSize, rect: CGRect, controller: UIViewController) {
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.sourceView = self.view
        controller.popoverPresentationController?.sourceRect = rect
        controller.popoverPresentationController?.permittedArrowDirections = .any
        controller.popoverPresentationController?.delegate = self
        controller.preferredContentSize = size
    }
}
