//
//  ScheduleView.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/07/05.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class ScheduleView: UIView {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var minute: UIImageView!
    @IBOutlet weak var endTime: UIImageView!
    @IBOutlet weak var chevronDown: UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
//        baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.5)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    func loadNib(){
        let view = Bundle.main.loadNibNamed("ScheduleView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func addLine(isMove: Bool, isStartLineHidden: Bool, isEndLineHidden: Bool) {
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 7, y: 0, width: baseView.frame.width - 7, height: 1.0)
        topBorder.backgroundColor = UIColor.black.cgColor
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: -1, y: 7, width: 1.5, height: baseView.frame.height - 7)
        leftBorder.backgroundColor = UIColor.black.cgColor
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: baseView.frame.height, width: baseView.frame.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.black.cgColor
        let centerBorder = CALayer()
        centerBorder.frame = CGRect(x: baseView.frame.width / 2, y: 0, width: 1.5, height: baseView.frame.height)
        centerBorder.backgroundColor = UIColor.black.cgColor

        if isStartLineHidden == false {
            baseView.layer.addSublayer(topBorder)
        }
        if isMove == false {
            baseView.layer.addSublayer(leftBorder)
            if isEndLineHidden == false {
                self.chevronDown.isHidden = false
                self.chevronDown.frame = CGRect(x: -9, y: baseView.frame.height - 12, width: 16, height: 16)
            }
            else {
                self.chevronDown.isHidden = true
            }
        }
        else {
            baseView.layer.addSublayer(centerBorder)
            self.chevronDown.isHidden = false
            self.chevronDown.frame = CGRect(x: baseView.frame.width / 2 - 8, y: baseView.frame.height - 12, width: 16, height: 16)
        }
        if isEndLineHidden == false {
            baseView.layer.addSublayer(bottomBorder)
            endTime.isHidden = true
        }
        else {
            endTime.isHidden = false
        }
    }
    
//    override func draw(_ rect: CGRect) {
//        let path = UIBezierPath()
//
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
//        path.close()
//
//        UIColor.red.setStroke()
//        path.stroke()
//    }

}
