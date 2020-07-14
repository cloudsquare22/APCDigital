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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
