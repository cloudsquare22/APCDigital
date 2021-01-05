//
//  EventFilterViewAddCell.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/12/29.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class EventFilterViewAddCell: UITableViewCell {
    weak var viewController: ViewController? = nil
    weak var eventFilterViewController: EventFilterViewController? = nil

    @IBOutlet weak var calendars: UIPickerView!
    @IBOutlet weak var filterString: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPicker() {
        self.calendars.dataSource = self
        self.calendars.delegate = self
    }
    
    @IBAction func tapAddEventFilter(_ sender: Any) {
        guard self.filterString.text?.isEmpty == false else {
            return
        }
        let calendarString = self.viewController?.calendars[self.calendars.selectedRow(inComponent: 0)].title
        EventFilter.insert(calendar: calendarString!, filterString: self.filterString.text!)
        self.eventFilterViewController?.reload()
        self.filterString.text = ""
    }
    
}

extension EventFilterViewAddCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.viewController?.calendars == nil {
            return 0
        }
        else {
            return (self.viewController?.calendars.count)!
        }
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        self.viewController?.calendars[row].title
//    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let color = UIColor(red: self.viewController!.calendars[row].cgColor.components![0],
                            green: self.viewController!.calendars[row].cgColor.components![1],
                            blue: self.viewController!.calendars[row].cgColor.components![2],
                            alpha: 1.0)
        let attribute = NSAttributedString(string: (self.viewController?.calendars[row].title)!,
                                           attributes: [NSAttributedString.Key.foregroundColor: color])
        return attribute
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let label = UILabel()
//        label.text = self.viewController?.calendars[row].title
//        label.adjustsFontSizeToFitWidth = true
//        label.textAlignment = .left
//        return label
//    }
}
