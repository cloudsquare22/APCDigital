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
    @IBOutlet weak var day4Holiday: UILabel!
    @IBOutlet weak var day5Holiday: UILabel!
    
    var pageMonday = Date()
    var days: [Int] = []
    
    var eventStore = EKEventStore()

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

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeft(sender:)))
        swipeLeft.direction = .left
        pKCanvasView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight(sender:)))
        swipeRight .direction = .right
        pKCanvasView.addGestureRecognizer(swipeRight)

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

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
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

    @objc func tapPKCanvasView(sender: UITapGestureRecognizer) {
        menuView.isHidden.toggle()
    }
    
    func updateDays() {
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
        days = []
        days.append(monday.day!)
        days.append(tuesday.day!)
        days.append(wednesday.day!)
        days.append(thursday.day!)
        days.append(friday.day!)
        days.append(saturday.day!)
        days.append(sunday.day!)
        self.month.text = String(monday.month!)
        self.fromDay.text = Calendar.current.shortStandaloneMonthSymbols[monday.month! - 1].uppercased() + " " + String(monday.day!)
        self.toDay.text = "to " + Calendar.current.shortStandaloneMonthSymbols[sunday.month! - 1].uppercased() + " " + String(sunday.day!)
        self.weekOfYear.text = String(Calendar.current.component(.weekOfYear, from: pageMonday)) + " week"
        
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
}

