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
    
    var week = 1
    var dateMonday = Date()
    
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

        let matching = DateComponents(weekday: 2)
        dateMonday = Calendar.current.nextDate(after: dateMonday, matching: matching, matchingPolicy: .nextTime, direction: .backward)!
        let monday = Calendar.current.dateComponents(in: .current, from: dateMonday)
        print(monday)
        self.day1.text = String(monday.day!)
        self.month.text = String(monday.month!)
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
        week = week + 1
        print(week)

        let matching = DateComponents(weekday: 2)
        dateMonday = Calendar.current.nextDate(after: dateMonday, matching: matching, matchingPolicy: .nextTime, direction: .forward)!
        let monday = Calendar.current.dateComponents(in: .current, from: dateMonday)
        print(monday)
        self.day1.text = String(monday.day!)
        self.month.text = String(monday.month!)
    }

    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        week = week - 1
        print(week)
        let matching = DateComponents(weekday: 2)
        dateMonday = Calendar.current.nextDate(after: dateMonday, matching: matching, matchingPolicy: .nextTime, direction: .backward)!
        let monday = Calendar.current.dateComponents(in: .current, from: dateMonday)
        print(monday)
        self.day1.text = String(monday.day!)
        self.month.text = String(monday.month!)
    }
}

