//
//  EventFilterViewCell.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/12/28.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class EventFilterViewCell: UITableViewCell {
    weak var eventFilterViewController: EventFilterViewController? = nil

    @IBOutlet weak var calendar: UILabel!
    @IBOutlet weak var filterString: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func tapDeleteEventFilter(_ sender: Any) {
        EventFilter.delete(calendar: self.calendar.text!, filterString: self.filterString.text!)
        self.eventFilterViewController?.reload()
    }
}
