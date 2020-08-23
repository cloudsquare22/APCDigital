//
//  EditEventsViewCell.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/23.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class EditEventsViewCell: UITableViewCell {

    @IBOutlet weak var calendarImage: UIImageView!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var eventText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
