//
//  EditScheduleViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/21.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit
import EventKit

class EditScheduleViewController: UIViewController {
    weak var viewController: ViewController? = nil
    
    var allday = false
    var startDate: Date? = nil
    var endDate: Date? = nil

    var eventStore = EKEventStore()

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var allDaySwitch: UISwitch!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var calendarPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDatePicker.date = startDate!
        self.endDatePicker.date = endDate!
        
        if allday == true {
            self.startDatePicker.datePickerMode = .date
            self.endDatePicker.datePickerMode = .date
        }
        
        self.calendarPicker.delegate = self
        self.calendarPicker.dataSource = self
        
        for index in 0..<(self.viewController?.calendars.count)! {
            if self.viewController?.calendars[index].title == eventStore.defaultCalendarForNewEvents?.title {
                self.calendarPicker.selectRow(index, inComponent: 0, animated: true)
                break
            }
        }
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeAllDaySwitch(_ sender: Any) {
        allday.toggle()
        if allday == true {
            self.startDatePicker.datePickerMode = .date
            self.endDatePicker.datePickerMode = .date
        }
        else {
            self.startDatePicker.datePickerMode = .dateAndTime
            self.endDatePicker.datePickerMode = .dateAndTime
        }
    }
    
    @IBAction func addCalendar(_ sender: Any) {
        let event = EKEvent(eventStore: eventStore)
        event.title = self.titleText.text
        event.startDate = self.startDatePicker.date
        event.endDate = self.endDatePicker.date
//        event.calendar = self.viewController?.calendars[calendarPicker.selectedRow(inComponent: 0)]
        event.calendar = eventStore.defaultCalendarForNewEvents
        if allday == true {
            event.isAllDay = true
        }
        do {
            try eventStore.save(event, span: .thisEvent)
            self.viewController?.pageUpsert()
            self.viewController?.updateDays()
            self.dismiss(animated: true, completion: nil)
        }
        catch {
            let nserror = error as NSError
            print(nserror)
        }
        //        let event = EKEvent(eventStore: eventStore)
        //        event.title = "Example Event"
        //        event.startDate = Date()
        //        event.endDate = Date() + (60 * 30)
        //        event.calendar = eventStore.defaultCalendarForNewEvents
        //        print(eventStore.defaultCalendarForNewEvents)
        //        do {
        //            try eventStore.save(event, span: .thisEvent)
        //        }
        //        catch {
        //            let nserror = error as NSError
        //            print(nserror)
        //
        //        }
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

extension EditScheduleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        (self.viewController?.calendars.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.viewController?.calendars[row].title
    }
    
}
