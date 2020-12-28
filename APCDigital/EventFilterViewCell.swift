//
//  EventFilterViewCell.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/12/28.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class EventFilterViewCell: UITableViewCell {
    weak var viewController: ViewController? = nil

    @IBOutlet weak var calendars: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.calendars.dataSource = self
        self.calendars.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension EventFilterViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
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

