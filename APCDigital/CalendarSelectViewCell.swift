//
//  CalendarSelectViewCell.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/07/14.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class CalendarSelectViewCell: UITableViewCell {

    @IBOutlet weak var display: UISwitch!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var inOut: UISegmentedControl!

    var index: Int = 0
    weak var tableView: CalendarSelectViewController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func tapDisplay(_ sender: Any) {
        tableView?.displayOnOff[index] = self.display.isOn
    }
    
    @IBAction func tapInOut(_ sender: Any) {
        if self.inOut.selectedSegmentIndex == 0 {
            self.tableView?.displayOut[index] = false
        }
        else {
            self.tableView?.displayOut[index] = true
        }
    }
}
