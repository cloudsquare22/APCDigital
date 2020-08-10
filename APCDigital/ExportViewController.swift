//
//  ExportViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/10.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController {
    weak var viewController: ViewController? = nil

    @IBOutlet weak var dateStart: UIDatePicker!
    @IBOutlet weak var dateEnd: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var start = Calendar.current.dateComponents(in: .current, from: self.viewController!.pageMonday)
        start.month = 1
        start.day = 1
        var end = Calendar.current.dateComponents(in: .current, from: self.viewController!.pageMonday)
        end.month = 12
        end.day = 31
        dateStart.date = start.date!
        dateEnd.date = end.date!
    }
    
    @IBAction func tapExport(_ sender: Any) {
        if dateStart.date < dateEnd.date {
            let aPCDCalendar = APCDCalendar()
            if let url = aPCDCalendar.export(fromDate: dateStart.date, toDate: dateEnd.date, displayCalendars: self.viewController!.displayCalendars) {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceRect = (sender as! UIButton).frame
                activityViewController.popoverPresentationController?.sourceView = self.view
                present(activityViewController, animated: true, completion: nil)
            }
        }
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
