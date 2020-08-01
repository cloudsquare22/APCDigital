//
//  MonthlyCarendarView.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/01.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class MonthlyCarendarView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("MonthlyCalendarView", owner: self, options: nil)?.first as! UIView
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
