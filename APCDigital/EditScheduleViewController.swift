//
//  EditScheduleViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/21.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class EditScheduleViewController: UIViewController {
    weak var viewController: ViewController? = nil
    
    var startDate: Date? = nil
    var endDate: Date? = nil

    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDatePicker.date = startDate!
        self.endDatePicker.date = endDate!

        // Do any additional setup after loading the view.
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
