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
    @IBOutlet weak var day1: UILabel!
    
    var week = 1
    
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
    }

    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        week = week - 1
        print(week)
    }
}

