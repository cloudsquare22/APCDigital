//
//  YearCalendarViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2021/07/11.
//  Copyright © 2021 shi-n. All rights reserved.
//

import UIKit

class YearCalendarViewController: UIViewController {
    weak var viewController: ViewController? = nil

    @IBOutlet weak var baseView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var nextMonth = self.viewController?.pageMonday
        for month in 0..<12 {
            let xpostion = month % 3
            let ypostion = month / 3
            self.baseView.addSubview(MonthlyCarendarView(frame: CGRect(x: 0 + (145 * xpostion), y: 0 + (105 * ypostion), width: 145, height: 105), day: nextMonth!, selectWeek: month == 0 ? true : false).view)
            nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: nextMonth!)
        }

//        self.baseView.addSubview(MonthlyCarendarView(frame: CGRect(x: 0, y: 0, width: 145, height: 105), day: self.viewController!.pageMonday).view)
//        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self.viewController!.pageMonday)
//        self.baseView.addSubview(MonthlyCarendarView(frame: CGRect(x: 145, y: 0, width: 145, height: 105), day: nextMonth!, selectWeek: false).view)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
