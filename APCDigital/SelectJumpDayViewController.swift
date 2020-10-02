//
//  SelectJumpDayViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/15.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class SelectJumpDayViewController: UIViewController {
    weak var viewController: ViewController? = nil

    @IBOutlet weak var selectDay: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        selectDay.date = Date()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func tapSelectDay(_ sender: Any) {
        var day = selectDay.date
        let weekday = Calendar.current.component(.weekday, from: day)
        if weekday != 2 {
            day = Calendar.current.nextDate(after: day, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .backward)!
        }
        self.viewController?.pageUpsert()
        self.viewController?.pageMonday = day
        self.viewController?.updateDays()
        self.dismiss(animated: true, completion: nil)
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
