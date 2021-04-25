//
//  ExportViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/10.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit
import Logging
import UniformTypeIdentifiers

class ExportViewController: UIViewController {
    weak var viewController: ViewController? = nil

    @IBOutlet weak var dateStart: UIDatePicker!
    @IBOutlet weak var dateEnd: UIDatePicker!
    
    let logger = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var start = Calendar.current.dateComponents(in: .current, from: self.viewController!.pageMonday)
        start.month = 1
        start.day = 1
        start.weekOfYear = 1
        start.yearForWeekOfYear = start.year
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
    
    @IBAction func tapFileExport(_ sender: Any) {
        logger.info()
        if dateStart.date < dateEnd.date {
            let aPCDCalendar = APCDCalendar()
            if let url = aPCDCalendar.exportFileAllPencilKitData() {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceRect = (sender as! UIButton).frame
                activityViewController.popoverPresentationController?.sourceView = self.view
                present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func tapFileImport(_ sender: Any) {
        logger.info("start")
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.apcd])
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func tapPKDataDelete(_ sender: Any) {
        if dateStart.date < dateEnd.date {
            var dateCurrent = dateStart.date
            while dateCurrent < dateEnd.date {
                let dateComponentsCurrent = Calendar.current.dateComponents(in: .current, from: dateCurrent)
                Pages.delete(year: dateComponentsCurrent.year!, week: dateComponentsCurrent.weekOfYear!)
                dateCurrent = Calendar.current.nextDate(after: dateCurrent, matching: ViewController.matching, matchingPolicy: .nextTime, direction: .forward)!
                let sunday = dateCurrent + (86400 * 6)
                if dateCurrent <= dateEnd.date && dateEnd.date < sunday {
                    break
                }
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

extension ExportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        logger.info("start")
        guard urls.count != 0 else {
            return
        }
        logger.info(urls.debugDescription)
//        self.delegate?.selectDocument(url: urls[0])
        let aPCDCalendar = APCDCalendar()
        aPCDCalendar.importFileAllPencilKitData(url: urls[0])
        self.viewController!.updateDays()        
    }
}

extension UTType {
  static var apcd: UTType {
    UTType(exportedAs: "jp.cloudsquare.document.apcd")
  }
}
