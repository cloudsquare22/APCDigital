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
    var baseEvent: EKEvent? = nil

    var eventStore: EKEventStore = EKEventStore()

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var allDaySwitch: UISwitch!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var calendarPicker: UIPickerView!
    @IBOutlet weak var todoSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var eventDeleteButton: UIButton!
    @IBOutlet weak var memoTexts: UITextView!
    @IBOutlet weak var memoDispSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventStore = self.viewController!.eventStore
        
        var selectCalendar = eventStore.defaultCalendarForNewEvents?.title
        
        if let event = baseEvent {
            self.locationText.text = event.location
            if event.isAllDay == true {
                self.allday = true
                self.allDaySwitch.isOn = true
            }
            selectCalendar = baseEvent?.calendar.title
            var title = event.title
            if title!.hasPrefix("□") == true {
                self.todoSwitch.isOn = true
                title!.removeFirst()
            }
            self.titleText.text = title
            eventDeleteButton.isHidden = false
            if let notes = event.notes {
                self.memoTexts.text = notes
                if notes.starts(with: "【memo on】\n") {
                    self.memoDispSwitch.isOn = true
                    let text = notes.replacingOccurrences(of: "【memo on】\n", with: "")
                    self.memoTexts.text = text
                }
            }
        }
        
        self.startDatePicker.date = startDate!
        self.endDatePicker.date = endDate!
        
        if allday == true {
            self.startDatePicker.datePickerMode = .date
            self.endDatePicker.datePickerMode = .date
            self.allDaySwitch.isOn = true
            self.notificationSwitch.isOn = false
        }
        
        self.calendarPicker.delegate = self
        self.calendarPicker.dataSource = self
        
        for index in 0..<(APCDData.instance.calendars.count) {
            if APCDData.instance.calendars[index].title == selectCalendar {
                self.calendarPicker.selectRow(index, inComponent: 0, animated: true)
                break
            }
        }
        
        self.memoTexts.layer.borderColor = UIColor.systemGray5.cgColor
        self.memoTexts.layer.borderWidth = 1
        self.memoTexts.layer.cornerRadius = 8
        self.memoTexts.layer.masksToBounds = true
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                 name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)),
        name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.viewController?.pKCanvasView.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Notification?) {
        print("keyboardWillShow")
        print(self.view.frame)
    }

    @objc func keyboardWillHide(_ notification: Notification?) {
        print("keyboardWillHide")
        print(self.view.frame)
    }

    @IBAction func changeAllDaySwitch(_ sender: Any) {
        allday.toggle()
        if allday == true {
            self.startDatePicker.datePickerMode = .date
            self.endDatePicker.datePickerMode = .date
            self.notificationSwitch.isOn = false
        }
        else {
            self.startDatePicker.datePickerMode = .dateAndTime
            self.endDatePicker.datePickerMode = .dateAndTime
        }
    }
    
    @IBAction func addCalendar(_ sender: Any) {
        guard !(self.titleText.text!.isEmpty) else {
            let alert = UIAlertController(title: "No title.", message: "Please enter a title.", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default, handler: { action in })
            alert.addAction(actionOK)
            present(alert, animated: true, completion: nil)
            return
        }
        let event = EKEvent(eventStore: eventStore)
        event.title = self.todoSwitch.isOn == true ? "□" : ""
        event.title = event.title + self.titleText.text!
        event.location = self.locationText.text
        event.startDate = self.startDatePicker.date
        event.endDate = self.endDatePicker.date
        let calendar = APCDData.instance.calendars[calendarPicker.selectedRow(inComponent: 0)]
        event.calendar = eventStore.calendar(withIdentifier: calendar.calendarIdentifier)
        if self.memoDispSwitch.isOn == true {
            event.notes = "【memo on】\n" + self.memoTexts.text
        }
        else {
            event.notes = self.memoTexts.text
        }
        if allday == true {
            event.isAllDay = true

            if self.notificationSwitch.isOn == true {
                let dateAllDayH = UserDefaults.standard.integer(forKey: "dateAllDayH")
                let dateAllDayM = UserDefaults.standard.integer(forKey: "dateAllDayM")
                let alarmToday = EKAlarm(relativeOffset: (60 * 60 * Double(dateAllDayH) + (60 * Double(dateAllDayM))))
                event.alarms = [alarmToday]
            }
        }
        else {
            if self.notificationSwitch.isOn == true {
                let alarmEvent = EKAlarm(relativeOffset: 0)
                let alarm5Minute = EKAlarm(relativeOffset: 60 * -5)
                event.alarms = [alarmEvent, alarm5Minute]
            }
        }
        do {
            if let baseEvent = self.baseEvent {
                try eventStore.remove(baseEvent, span: .thisEvent)
            }
            try eventStore.save(event, span: .thisEvent)
            self.viewController?.pageUpsert()
            self.viewController?.updateDays()
//            self.viewController?.pKCanvasView.becomeFirstResponder()
            self.dismiss(animated: true, completion: nil)
        }
        catch {
            let nserror = error as NSError
            print(nserror)
        }
    }
    
    @IBAction func deleteCalendar(_ sender: Any) {
        print("Event Delete")
        do {
            try self.eventStore.remove(self.eventStore.event(withIdentifier: self.baseEvent!.eventIdentifier)!, span: .thisEvent)
            self.viewController?.pageUpsert()
            self.viewController?.updateDays()
            self.dismiss(animated: true, completion: nil)
        }
        catch {
            let nserror = error as NSError
            print(nserror)
        }
    }
    
    @IBAction func addEnd0_5(_ sender: Any) {
        let start = self.startDatePicker.date
        self.endDatePicker.date = Calendar.current.date(byAdding: .minute, value: 30, to: start)!
    }
    
    @IBAction func addEnd1_0(_ sender: Any) {
        let start = self.startDatePicker.date
        self.endDatePicker.date = Calendar.current.date(byAdding: .minute, value: 60, to: start)!
    }
    
    @IBAction func addEnd1_5(_ sender: Any) {
        let start = self.startDatePicker.date
        self.endDatePicker.date = Calendar.current.date(byAdding: .minute, value: 90, to: start)!
    }
    
    @IBAction func addEnd2_0(_ sender: Any) {
        let start = self.startDatePicker.date
        self.endDatePicker.date = Calendar.current.date(byAdding: .minute, value: 120, to: start)!
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
        (APCDData.instance.calendars.count)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        APCDData.instance.calendars[row].title
    }
    
}
