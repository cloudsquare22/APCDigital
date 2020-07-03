//
//  ViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/07/03.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit
import PencilKit

class ViewController: UIViewController {

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
    
    var pageMonday = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pKCanvasView.allowsFingerDrawing = false
        pKCanvasView.isOpaque = false
        pKCanvasView.backgroundColor = .clear
        pKCanvasView.overrideUserInterfaceStyle = .light

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let window = self.pKCanvasView.window {
            let toolPicker = PKToolPicker.shared(for: window)
            toolPicker?.addObserver(pKCanvasView)
            toolPicker?.setVisible(true, forFirstResponder: pKCanvasView)
            toolPicker?.overrideUserInterfaceStyle = .light
            pKCanvasView.becomeFirstResponder()
            print("PKToolPicker Set")
        }
    }

    @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
        let matching = DateComponents(weekday: 2)
        pageMonday = Calendar.current.nextDate(after: pageMonday, matching: matching, matchingPolicy: .nextTime, direction: .forward)!
        updateDays()
    }

    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        let matching = DateComponents(weekday: 2)
        pageMonday = Calendar.current.nextDate(after: pageMonday, matching: matching, matchingPolicy: .nextTime, direction: .backward)!
        updateDays()
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
        self.month.text = String(monday.month!)
        self.fromDay.text = Calendar.current.shortStandaloneMonthSymbols[monday.month! - 1] + " " + String(monday.day!)
        self.toDay.text = "to " + Calendar.current.shortStandaloneMonthSymbols[sunday.month! - 1] + " " + String(sunday.day!)
        self.weekOfYear.text = String(Calendar.current.component(.weekOfYear, from: pageMonday)) + " week"
    }
    
}

