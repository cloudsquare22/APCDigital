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
    
    func addLine(isMove: Bool) {
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 7, y: 0, width: baseView.frame.width - 7, height: 1.0)
        topBorder.backgroundColor = UIColor.black.cgColor
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: 0, y: 7, width: 1.5, height: baseView.frame.height - 7)
        leftBorder.backgroundColor = UIColor.black.cgColor
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: baseView.frame.height, width: baseView.frame.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.black.cgColor
        let centerBorder = CALayer()
        centerBorder.frame = CGRect(x: baseView.frame.width / 2, y: 0, width: 1.5, height: baseView.frame.height)
        centerBorder.backgroundColor = UIColor.black.cgColor

        baseView.layer.addSublayer(topBorder)
        if isMove == false {
            baseView.layer.addSublayer(leftBorder)
        }
        else {
            baseView.layer.addSublayer(centerBorder)
        }
        baseView.layer.addSublayer(bottomBorder)
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
