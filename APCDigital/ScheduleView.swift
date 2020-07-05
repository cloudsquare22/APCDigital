//
//  ScheduleView.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/07/05.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class ScheduleView: UIView {

    @IBOutlet var baseView: UIView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
//        baseView.backgroundColor = UIColor(red: 1, green: 0.58, blue: 0, alpha: 0.5)

        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: baseView.frame.width, height: 1.0)
        topBorder.backgroundColor = UIColor.black.cgColor
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: 0, y: 0, width: 1.0, height: baseView.frame.height)
        leftBorder.backgroundColor = UIColor.black.cgColor
        baseView.layer.addSublayer(topBorder)
        baseView.layer.addSublayer(leftBorder)
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

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
